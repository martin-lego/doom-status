# Doom Status

App nativa de barra de menú para macOS. Muestra el uso de CPU de toda la máquina con las caras de Doom: cuanto más alta la carga, más lastimado se ve el personaje.

El binario es arm64, para Macs con Apple Silicon (M1 en adelante). Requiere macOS 14 o posterior.

## Instalación

1. Entra a [Releases](https://github.com/martin-lego/doom-status/releases) y descarga `DoomStatus.dmg`.
2. Abre la imagen de disco.
3. Arrastra **Doom Status** a la carpeta **Aplicaciones**.
4. Abre **Doom Status** desde Aplicaciones. La cara aparece en la barra de menú.

Al bajar la app de internet, macOS no la abre con doble clic la primera vez, porque no está notarizada. Haz clic derecho (o Control-clic) sobre **Doom Status**, elige **Abrir** y confirma en el diálogo. A partir de ahí se abre normal.

No hay notarización. Eso pide una cuenta de Apple Developer de pago, y no entra en este proyecto.

## Uso

El menú muestra el porcentaje de CPU global (el promedio de la máquina, no un núcleo suelto), **About** y **Quit**. La lectura se actualiza cada 5 segundos.

| CPU | Archivo |
| --- | --- |
| 0–16 | 1.png |
| 17–33 | 2.png |
| 34–50 | 3.png |
| 51–67 | 4.png |
| 68–84 | 5.png |
| 85–100 | 6.png |

## Compilar

En un Mac con Apple Silicon y las herramientas de Xcode:

```bash
bash scripts/build-dmg.sh
```

El instalador queda en `dist/DoomStatus.dmg`.

## Créditos

Las caras son de DOOM, de id Software. Los seis PNG (`1.png` … `6.png`) vienen de [rjzak/doom-status](https://github.com/rjzak/doom-status).

## Licencia

[GNU GPL-2.0](LICENSE).
