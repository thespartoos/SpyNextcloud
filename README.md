## Nextcloud 3 level of users

![[nextcloud.png]]

**Nextcloud** es una serie de programas cliente-servidor que permiten la creación de servicios de alojamiento de archivos. Su funcionalidad es similar al software Dropbox, aunque Nextcloud en su totalidad de código abierto. Nextcloud permite a los usuarios crear servidores privados.

Esta herramienta consigue crear 3 niveles de usuarios simplemente jugando con las API y WebDAV de los usuarios del FileManager.

```
:warning: Esta herramienta esta diseñada para su uso en un CentOs testeado en concreto en la version (CentOs 7)
```

### Usage
Para poder ejecutarla correctamente debes especificar la **url** sin la última barra al final para que no haya problemas. Hay un panel de ayuda con ejemplos para que te quede mas clara la ejecución

![[menu.png]]

### Modos

##### SharedMode

Este modo te permite que todos los archivos y carpetas de todos los usuarios se compartan al usuario administrador que tengais configurado.

![[sharedmode.png]]

![[final_shared.png]]

##### CopyMode

Este modo es "indetectable" te permite copiar todos los archivos y directorios de todos los usuarios al usuario Administrador que tengais configurado.

![[copymode.png]]

![[final_shared.png]]