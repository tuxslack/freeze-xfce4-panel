#!/bin/bash
#
# Autor:       Cláudio A. Silva <https://github.com/claudioduzeru>
# Data:        26/02/2016 as 08:59
#
# Colaboração: Fernando Souza - https://www.youtube.com/@fernandosuporte/
# Data:        13/05/2025 as 01:25:45
# Homepage:    https://github.com/tuxslack/freeze-xfce4-panel
#
# Licença padrão GLP v2
#
#
# Função:  Este script tem como função travar o painel do XFCE (versão 4.20.3), impedindo 
# que ele seja modificado até ser liberado novamente.
# 
# 
# Considerações:
# 
#     O termo "congelar" aqui significa impedir que o painel seja modificado por usuários 
# que não sejam Root.
# 
#     Esse comportamento depende do suporte do XFCE ao atributo unlocked="root" no XML, 
# que, embora não seja oficial na documentação, pode funcionar como um controle de travamento 
# se interpretado dessa forma por xfce4-panel.
# 
# 
# O que este script cobre:
# 
#     Todos os ficheiros xfce4-panel*.xml dentro da pasta de configuração do XFCE.
# 
#     Interface gráfica com yad.
# 
#     Reaplica permissões e reinicia o painel após a mudança.
# 
#     Usa chattr e chmod em todos os ficheiros encontrados.
#
# 
#
# This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Tradução não-oficial:
#
#    Este programa é um software livre; você pode redistribuí-lo e/ou
#    modificá-lo dentro dos termos da Licença Pública Geral GNU como
#    publicada pela Fundação do Software Livre (FSF); na versão 3 da
#    Licença, ou (na sua opinião) qualquer versão.
#
#    Este programa é distribuído na esperança de que possa ser útil,
#    mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO
#    a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a
#    Licença Pública Geral GNU para maiores detalhes.
#
#    Você deve ter recebido uma cópia da Licença Pública Geral GNU junto
#    com este programa. Se não, veja <http://www.gnu.org/licenses/>.



# ----------------------------------------------------------------------------------------

# ChangeLog



# 12/05/2025  Fernando Souza  <https://github.com/tuxslack>

# Modificação do /etc/xdg/... não tem prioridade:

#  O XFCE carrega primeiro os ficheiros de configuração do utilizador em ~/.config/xfce4/xfconf/..., não os do sistema (/etc/xdg/...).

#  Ou seja, copiar a configuração para /etc/xdg não bloqueia nada se o utilizador tiver sua própria cópia.



# 09/05/2025  Fernando Souza  <https://github.com/tuxslack>

# Com essas mudanças, o script agora não precisa reiniciar o sistema inteiro - apenas o 
# painel do xfce será recarregado com as novas configurações aplicadas.

# * Trocado "sudo shutdown -r now" por "xfce4-panel --restart"
# * Verificar se os programas estão instalados
# * Trocado "echo" por "yad"
# * Verificação de arquivos e diretórios
# * Verificar se o ambiente gráfico é XFCE
# * Corrigido a cor dos textos do echo


# 26/02/2016 Cláudio A. Silva <https://github.com/duzerulinux>

# Criação do script



# ----------------------------------------------------------------------------------------

clear


# Caminhos:

logotipo="/usr/share/pixmaps/duzeru-freezepanel.png"


USUARIO_REAL=$(logname)  # ou use `who | awk '{print $1}' | head -n1`


HOME_REAL=$(eval echo "~$USUARIO_REAL")


# Diretório de configuração do painel XFCE

PASTA_USUARIO="$HOME_REAL/.config/xfce4/xfconf/xfce-perchannel-xml"


# Caminho do arquivo de configuração do painel:

PAINEL_XML="$PASTA_USUARIO/xfce4-panel.xml"



# Arquivo de log (para auditoria ou debug das ações feitas):

log="/tmp/xfce4-panel.log"



# echo $PAINEL_XML

# exit 

# ----------------------------------------------------------------------------------------



# Verificar se os programas estão instalados


which yad 1> /dev/null 2> /dev/null || { echo "Programa Yad não esta instalado." ; exit ; }



REQUIRED_CMDS=(sudo shutdown cp sed xfce4-panel notify-send xfce4-terminal)


for cmd in "${REQUIRED_CMDS[@]}"; do

    if ! command -v "$cmd" >/dev/null 2>&1; then

        yad --center --window-icon="$logotipo" --error --title="Erro de Dependência" --text="O comando \"$cmd\" não está instalado ou não está no PATH." --buttons-layout=center --button=OK:0 2>/dev/null

        exit 1
    fi

done


# ----------------------------------------------------------------------------------------

clear


if [ "$EUID" -ne 0 ]; then

    yad --center --error --title="Permissão Negada" --text="Este script precisa ser executado como Root."

    exit 1

fi


# ----------------------------------------------------------------------------------------

# Remove o arquivo de log

rm -f "$log" 2>/dev/null


# ----------------------------------------------------------------------------------------

# Verificar se o ambiente gráfico é XFCE


if [ "$XDG_CURRENT_DESKTOP" != "XFCE" ] && [ "$XDG_SESSION_DESKTOP" != "xfce" ]; then

    yad --center --window-icon="$logotipo" --error --title="Ambiente Incompatível" --text="Este script só pode ser executado no ambiente gráfico XFCE." --buttons-layout=center --button=OK:0 2>/dev/null

    exit 1

fi

# ----------------------------------------------------------------------------------------


# Verifica existência da pasta

if [ ! -d "$PASTA_USUARIO" ]; then

    yad --center --error --title="Erro" --text="Diretório não encontrado:\n$PASTA_USUARIO"

    exit 1

fi

# ----------------------------------------------------------------------------------------


# Verifica existência do arquivo

if [ ! -f "$PAINEL_XML" ]; then

    yad --center --error --title="Erro" --text="Arquivo não encontrado:\n$PAINEL_XML"

    exit 1

fi


# ----------------------------------------------------------------------------------------

# Função para reiniciar o painel

reiniciar_painel(){

    xfce4-panel --restart   2>> "$log"

    ls -l "$PASTA_USUARIO"  2>> "$log"

}


# ----------------------------------------------------------------------------------------


# Função para congelar o painel do xfce


congelar() {


    echo -e "\n❄️ Congelar painel...\n"

# Para nomes com espaços

IFS=$'\n'

    for arq in $arquivos_panel; do

        chmod a-w "$arq"      2>> "$log"

        sudo chattr +i "$arq" 2>> "$log"

    done

unset IFS


    echo "Você escolheu travar. Reiniciando o painel XFCE..."

    yad --center --window-icon="$logotipo" --info --title="Painel Congelado" --text="Todos os arquivos de painel foram congelados com sucesso.\n\n\nO painel não poderá ser alterado, nem via interface nem terminal. Até o Root precisa remover o atributo imutável para alterar." --buttons-layout=center --button=OK:0 2>/dev/null


   # Para reiniciar apenas o xfce4-panel

   reiniciar_painel

}



# ----------------------------------------------------------------------------------------

# Função para descongelar o painel do xfce


descongelar(){


    echo -e "\n🔓 Descongelar painel...\n"

# Para nomes com espaços

IFS=$'\n'

    for arq in $arquivos_panel; do

        sudo chattr -i "$arq" 2>> "$log"

        chmod u+w "$arq"      2>> "$log"

    done

unset IFS


    echo "Você escolheu destravar. Reiniciando o painel XFCE..."

    yad --center --window-icon="$logotipo" --info --title="Painel Descongelado" --text="Todos os arquivos de painel foram desbloqueados com sucesso." --buttons-layout=center --button=OK:0 2>/dev/null


   # Para reiniciar apenas o xfce4-panel

   reiniciar_painel

}


# ----------------------------------------------------------------------------------------

# Procura por todos os arquivos relacionados ao painel

arquivos_panel=$(find "$PASTA_USUARIO" -type f -name "*xfce4-panel*.xml")

if [ -z "$arquivos_panel" ]; then

    yad --center --error --title="Erro" --text="Nenhum arquivo xfce4-panel*.xml encontrado."

    exit 1
fi

# ----------------------------------------------------------------------------------------

# Log inicial

echo -e "\n\nVersão do painel: $(xfce4-panel --version)\n\n" > "$log"


# ----------------------------------------------------------------------------------------

# Notificação

    notify-send -t 40000 -i edit-paste "Painel do XFCE" \
"
Ao final do processo verifique o arquivo de log: $log.
"

# ----------------------------------------------------------------------------------------



############## APRESENTAÇÃO ###############################

echo -e '
*====================================================================*
||  \e[34;1m ####%.         ########                      \e[m                  ||
||  \e[34;1m ######.        #"""###                       \e[m                  ||
||  \e[34;1m ##   ## ##  ##     ## .;##;. ##  ,## ##  ##  \e[m                  ||
||  \e[34;1m ##   ## ##  ##    ##  ##"  #  ##.#"  ##  ##  \e[m                  ||
||  \e[34;1m ##   ## ##  ##   ##   ##  ,#  ##"`   ##  ##  \e[m                  ||
||  \e[34;1m ##   ## ##  ##  ##    ####"   ##     ##  ##  \e[33;1m      \e[32;1m    \\\e[m\e[33;1mo\e[m\e[32;1m/ \e[m    ||
||  \e[34;1m ######" ##..## ###..# "#.     ##     ##..##  \e[32;1mSistema   \e[33;1m # \e[m     ||
||  \e[34;1m #####%¨ "####"#######  "####  ##     "####"  \e[32;1mGNU\e[m\e[33;1m/\e[m\e[32;1mLinux\e[m\e[32;1m_/ \_ \e[m   ||
*====================================================================*

'



# Mensagens de aviso

echo -e "\n\e[32;1mVou auxiliar na segurança do painel, preciso da senha.\e[m"
echo -e "\e[31;1mATENÇÃO!\e[m"
echo -e "\e[32;1mApós digitar a senha, o painel será reiniciado.\n\e[m"


############## FIM APRESENTAÇÃO ###############################


# Confirmação

yad \
--center \
--window-icon="$logotipo" \
--info \
--title="Segurança do Painel" \
--text="Vou auxiliar na segurança do painel.\n\n⚠️ ATENÇÃO ⚠️\n\nApós digitar a senha, o painel será reiniciado." \
--buttons-layout=center \
--button=Cancelar:1 --button=OK:0 \
2>/dev/null




resposta=$?

if [ "$resposta" -eq 1 ]; then

    clear

    exit
fi


############## Escolha da opção ###################
 

# Mostrar menu de opções


# resposta=$(yad --center --window-icon="$logotipo" --entry --title="Painel XFCE" --text="Escolha uma opção:\n\nd - Descongelar painel (Unfreeze)\nc - Congelar painel (Freeze)" --entry-text="d" "c")


yad --center \
    --window-icon="$logotipo" \
    --title="Painel XFCE" \
    --text="Escolha a ação desejada para o painel XFCE." \
    --buttons-layout=center \
    --button="❄️ Congelar painel":0 \
    --button="🔓 Decongelar painel":2 \
    --width="450" --height="150" \
     2>/dev/null


resposta=$?

if [ "$resposta" -eq 1 ]; then

    clear

    exit
fi



############## Ações ###############################

if [ "$resposta" -eq 0 ]; then


    # 🔒 Congelar (Freezer):


    # Isso provavelmente força o painel a ficar bloqueado contra alterações de usuários comuns.


    # Para congelar o painel do xfce

    congelar


    echo "O painel foi congelado com sucesso.\n\nImpossível editar até desbloquear."


elif [ "$resposta" -eq 2 ]; then


    # 🔓 Descongelar (Unfreeze):


    # Para descongelar o painel do xfce

    descongelar


    echo "O painel foi descongelado.\n\nAgora pode ser editado normalmente."

else

    # Cancelado ou outro código

    exit 1

fi


# ----------------------------------------------------------------------------------------

clear

exit 0

