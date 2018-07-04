# Recalbox-Clcd

Affiche des informations sur un écran LCD compact pour les version 4.X de recalbox pour raspberry.

![ ](http://i.imgur.com/CGAyTAlm.jpg)

## A propos

Script écrit en python pour le projet recalbox <http://recalbox.com>
tournant sur raspberry, qui affichera diverses informations sur un écran lcd 16X2
**Pour afficher les informations sur vos jeux, vos roms doivent être scrappés.**

## Remerciement

* Version originale du script recalbox par Godhunter74
* Projet d'origine sur retropie par zzeromin <https://github.com/zzeromin/RetroPie-Clcd>
* Merci à zzeromin smyani, zerocool, GreatKStar
* L'équipe Recalbox <http://www.recalbox.com>

## Fonctionnalité

* Affichage de la date et l'heure
* Affichage des adresses ip réseaux ethernet ou wifi
* Affichage de la T° et fréquence du CPU
* Affichage d'information relative aux roms en cours de jeu.
* Un script daemon est fourni pour gérer l'allumage et l'extinction de l'affichage

## Environnement de développement

* Raspberry Pi 3
* Recalbox 18.02.09
* 16x2 I2C HD447800 LCD (A00)

## Installation

## Prérequis

recalbox en version 4.x ou supérieure.
Un écran CLCD I2c comme le modèle Hd44780 en version A00 (support ascii + caractères japonais) ou A02 (support ascii + caractères européen)

![ ](http://i.imgur.com/YrDDhwUm.jpg)

### Branchement I2C sur GPIO Raspberry Pi 3

Connexion de l'I2c sur un raspberry pi 3

![ ](http://i.imgur.com/NKswbgr.png)

## Installation automatique avec le script clcld-install.sh

* Connectez vous en SSH sur votre recalbox et monter la partition en lecture-écriture.

```Bash
mount -o remount, rw /
```
* Copiez le fichier clcd-install.sh dans **/recalbox/scripts**
* Exécuter le script avec la commande :
```shell
sh clcd_install.sh
```
* Suivez les instructions à l'écran pour effectuer l'installation.
     
Note: Il se peut que vous deviez relancer le scripts pour terminer l'installation après le redémarrage effectuée par le script (indiqué à l'écran).
Le script propose aussi une option de désinstallation de Recalbox-clcd

## Installation manuelle

### Activation de l'I2C dans recalbox

* Connectez vous en SSH sur votre recalbox et monter la partition en lecture-écriture.

```Bash
mount -o remount, rw /
```

* Editez le fichier /etc/modules.conf
* Ajoutez à la fin du fichier

```txt
i2c-bcm2708
i2c-dev
```

* Editez le fichier /boot/config.txt
* Ajouter les lignes suivantes :

```txt
#Activate I2C
dtparam=i2c1=on
dtparam=i2c_arm=on
```

* Editez le fichier /boot/cmdline.txt
* ajoutez à **la fin de ligne**

```txt
bcm2708.vc_i2c_override=1
```

* rédémarrez votre recalbox

### Vérifier l'adresse de l'I2C

Vous devrez connaitre l'adresse de votre I2C pour faire fonctionner les scripts.
En règle générale, l'adresse est 0x27 ou 0x3f

Lancez la commande suivante (celle-ci prend un certain temps pour se terminer)

```txt
i2cdetect -y 1
```

```Txt
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- 27 -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
```

Nous voyons ici dans notre tableau que l'adresse de l'I2C qui nous est retourné est 0x27, celle-ci servira ensuite comme paramètre dans un des fichiers scripts.

### Installation des scripts

* Connectez vous en SSH sur votre recalbox et monter la partition en lecture-écriture.

```Bash
mount -o remount, rw /
```

* Copiez le dossier **clcd** dans le dossier **/recalbox/scripts** avec un logiciel comme winscp par exemple

* Vérifiez que les fichiers
        recalbox_clcd.py
        recalbox_clcd.lang
        recalbox_clcd_off.py
        recalbox_clcd.lang
        I2C_LCD_driver.py
        lcdScroll.py
    sont présent dans le dossier **/recalbox/scripts/clcd/**

* Copiez
        S97LCDInfoText
    dans **/etc/init.d/**

* Puis donner le droit d'execution sur l'ensemble des fichiers

```Bash
chmod +x /recalbox/scripts/clcd/recalbox_clcd_off.py
chmod +x /recalbox/scripts/clcd/recalbox_clcd.py
chmod +x /recalbox/scripts/clcd/I2C_LCD_driver.py
chmod +x /recalbox/scripts/clcd/lcdScroll.py
chmod +x /recalbox/scripts/clcd/recalbox_clcd.lang
chmod +x /etc/init.d/S97LCDInfoText
```

editez la ligne #22 du fichier I2C_LCD_driver.py dans /recalbox/scripts avec l'adresse de votre I2C récupéré précédemment (dans notre exemple 0x27).

```python
nano I2C_LCD_driver.py

# LCD Address
ADDRESS = 0x27 # or 0x3f
```

* rédémarrez votre recalbox, le script devrait maintenant se lancer automatiquement au démarrage, et l'afficheur se couper à l'extinction de votre recalbox.

## Information importante

Pour afficher les informations relative au jeu Scummvm sur l'afficheur, ces derniers doivent être scrappé dans le fichier gamelist.xml en pointant sur leur dossier plutot que sur le fichier scummvm.

```txt
<path>./FT/</path>
au lieu de
<path>./FT/ft.scummvm</path>
```

## Photos

![ ](http://i.imgur.com/PEAyQm2m.jpg)
![ ](http://i.imgur.com/fsXfArEm.jpg)
![ ](http://i.imgur.com/qesmRu6m.jpg)

## Liens

* <https://forum.recalbox.com/topic/8689/script-clcd-display-on-recalbox>
* <https://forum.recalbox.com/topic/5777/relier-%C3%A0-un-%C3%A9cran-et-afficher-du-texte/121>
