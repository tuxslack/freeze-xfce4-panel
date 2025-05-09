#!/bin/bash
#
# Autor:       Cláudio A. Silva <claudiosilva@duzeru.org>
# Data:        26/02/2016 as 08:59
#
# Colaboração: Fernando Souza - https://www.youtube.com/@fernandosuporte/
# Data:        09/05/2025 as 03:29:56
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


# 09/05/2025  Fernando Souza  <https://github.com/tuxslack>

# Com essas mudanças, o script agora não precisa reiniciar o sistema inteiro - apenas o 
# painel do xfce será recarregado com as novas configurações aplicadas.

# * Trocado "sudo shutdown -r now" por "xfce4-panel --restart"
# * Verificar se os programas estão instalados
# * Trocado "echo" por "yad"
# * Verificação de arquivos e diretórios
# * Verificar se o ambiente gráfico é XFCE


# 26/02/2016 Cláudio A. Silva <https://github.com/duzerulinux>

# Criação do script


# ----------------------------------------------------------------------------------------


clear


# Verificar se os programas estão instalados


which yad           1> /dev/null 2> /dev/null || { echo "Programa Yad não esta instalado."      ; exit ; }



REQUIRED_CMDS=(sudo shutdown cp sed xfce4-panel notify-send xfce4-terminal)


for cmd in "${REQUIRED_CMDS[@]}"; do

    if ! command -v "$cmd" >/dev/null 2>&1; then

        yad --center --window-icon="$logotipo" --error --title="Erro de Dependência" --text="O comando \"$cmd\" não está instalado ou não está no PATH." 2>/dev/null

        exit 1
    fi

done



# ----------------------------------------------------------------------------------------

# Caminhos:

logotipo="/usr/share/pixmaps/duzeru-freezepanel.png"


# Pasta do usuário: 

PASTA_USUARIO="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"


# Pasta do sistema:

PASTA_SISTEMA="/etc/xdg/xfce4/xfconf/xfce-perchannel-xml"


# Arquivo de configuração do painel:

ARQUIVO="xfce4-panel.xml"


# Arquivo de log:

log="/tmp/xfce4-panel.log"

# ----------------------------------------------------------------------------------------

# Verificar se o ambiente gráfico é XFCE


if [ "$XDG_CURRENT_DESKTOP" != "XFCE" ] && [ "$XDG_SESSION_DESKTOP" != "xfce" ]; then

    yad --center --window-icon="$logotipo" --error --title="Ambiente Incompatível" --text="Este script só pode ser executado no ambiente gráfico XFCE."

    exit 1

fi

# ----------------------------------------------------------------------------------------

# Verificação de arquivos e diretórios:


if [ ! -d "$PASTA_USUARIO" ] || [ ! -f "$PASTA_USUARIO/$ARQUIVO" ]; then

    yad --center --window-icon="$logotipo" --error --title="Erro" --text="Arquivo ou pasta do usuário não encontrados: $PASTA_USUARIO/$ARQUIVO"

    exit 1
fi


if [ ! -d "$PASTA_SISTEMA" ]; then

    yad --center --window-icon="$logotipo" --error --title="Erro" --text="Pasta do sistema não encontrada: $PASTA_SISTEMA" --button=OK:0 2>/dev/null

    exit 1
fi

# ----------------------------------------------------------------------------------------

# Remove o arquivo de log

rm -Rf "$log" 2>/dev/null


clear


# ----------------------------------------------------------------------------------------

echo "
Versão do painel: `xfce4-panel --version`
" > "$log"


# ----------------------------------------------------------------------------------------

    # Envia notificação sobre o arquivo de log

    notify-send -t 40000 -i edit-paste "Panel do xfce" \
"
Ao final do processo verifica o arquivo de log $log.
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
*====================================================================*'


# Mensagens informativas

echo -e "\n\e[32;1mVou auxiliar na segurança do painel, preciso da senha.\e[m"
echo -e "\e[31;1mATENÇÃO!\e[m"
echo -e "\e[32;1mApós digitar a senha, o sistema será reiniciado.\e[m"
echo ''
echo -e "\e[32;1mI will assist in security panel, I need the root password.\e[m"
echo -e "\e[31;1mWARNING!\e[m"
echo -e "\e[32;1mAfter entering the password, the system will reboot.\e[m"


############## FIM APRESENTAÇÃO ###############################



yad \
--center \
--window-icon="$logotipo" \
--info \
--title="Segurança do Painel" \
--text="Vou auxiliar na segurança do painel.\n\n⚠️ ATENÇÃO ⚠️\n\nApós digitar a senha, o sistema será reiniciado.\n\nI will assist in security panel, I need the root pass.\n\n⚠️ WARNING ⚠️\n\nAfter entering the password, the system will reboot." \
--button=Cancelar:1 --button=OK:0 \
2>/dev/null


if [ "$?" == "1" ];
then 

     exit
     
fi

############## Escolha da opção ###################
 

# resposta=$(yad --center --window-icon="$logotipo" --entry --title="Painel XFCE" --text="Escolha uma opção:\n\nd - Descongelar painel (Unfreeze)\nc - Congelar painel (Freeze)" --entry-text="d" "c")


yad --center \
    --window-icon="$logotipo" \
    --title="Painel XFCE" \
    --button="❄️ Congelar painel":0 \
    --button="🔓 Decongelar painel":1 \
    --text="Escolha a ação desejada para o painel XFCE." \
    --width="450" --height="150" \
     2>/dev/null

resposta=$?



############## Lógica de Escolha ###############################

if [ "$resposta" -eq 0 ]; then


    # 🔒 Congelar (Freezer):


    # Isso provavelmente força o painel a ficar bloqueado contra alterações de usuários comuns.


    echo -e "\nCongelar...\n"


    # Copia o arquivo do usuário para o diretório do sistema (/etc/xdg/...).

    sudo cp -a "$PASTA_USUARIO/$ARQUIVO" "$PASTA_SISTEMA/" 2>> "$log"


    # Altera a tag <channel name="xfce4-panel" version="1.0"> para incluir o atributo unlocked="root".

    sudo sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" unlocked="root">/g' "$PASTA_SISTEMA/$ARQUIVO" 2>> "$log"


    # Exibe uma mensagem com o yad e reinicia o sistema para aplicar a configuração.

    # yad --center --window-icon="$logotipo" --info --title="Congelar Painel" --text="Você escolheu travar.\nO sistema será reiniciado para aplicar as configurações." --button=OK:0 2>/dev/null


    # echo "Você escolheu travar, aguarde vou reiniciar para 
# finalizar as configurações até logo..."

#    sleep 5


    # sudo shutdown -r now



    yad --center --window-icon="$logotipo" --info --title="Congelar Painel" --text="Você escolheu travar.\nO painel será reiniciado agora para aplicar as configurações." --button=OK:0 2>/dev/null

    echo "Você escolheu travar. Reiniciando o painel XFCE..."


    # Para reiniciar apenas o xfce4-panel

    xfce4-panel --restart


else


    # 🔓 Descongelar (Unfreeze):


    echo -e "\nDescongelar...\n"

    # Repete a cópia do arquivo do usuário para o sistema.

    sudo cp -a "$PASTA_USUARIO/$ARQUIVO" "$PASTA_SISTEMA/"  2>> "$log"


    # Remove o atributo unlocked="root" do arquivo.

    sudo sed -i 's/<channel name="xfce4-panel" version="1.0" unlocked="root">/<channel name="xfce4-panel" version="1.0">/g' "$PASTA_SISTEMA/$ARQUIVO" 2>> "$log"


    # Exibe uma mensagem e reinicia novamente o sistema para aplicar.

    # yad --center --window-icon="$logotipo" --info --title="Descongelar Painel" --text="Você escolheu destravar.\nO sistema será reiniciado para aplicar as configurações." --button=OK:0 2>/dev/null

    # echo "Você escolheu destravar, aguarde vou reiniciar para 
# finalizar as configurações até logo..."

#    sleep 5


    # sudo shutdown -r now



    yad --center --window-icon="$logotipo" --info --title="Descongelar Painel" --text="Você escolheu destravar.\nO painel será reiniciado agora para aplicar as configurações." --button=OK:0 2>/dev/null

    echo "Você escolheu destravar. Reiniciando o painel XFCE..."


    # Para reiniciar apenas o xfce4-panel

    xfce4-panel --restart


fi


# ----------------------------------------------------------------------------------------

exit 0

