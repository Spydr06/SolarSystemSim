# SolarSystemSim 
### Ein 3D Simultor für Gravitationskräfte zwischen Körpern

![demo](https://raw.githubusercontent.com/Spydr06/SolarSystemSim/main/demo.png)

### Systemanforderungen:
- Processing 4
 
### Was der Code kann: 
- Simulation von Gravitationskräften zwischen (praktisch) beliebig vielen Objekten (theoretisch limitiert durch das 32-Bit Integer limit von `2147483647`, praktisch durch performance- und Speicherlimits)
- 3D-Editorkamera und -steuerung:

_Maus_ zum Rotieren von X und Z Achse

_CTRL + Maus_ zum Verschieben des Koordinatensystems

_CTRL + R_ zum Zurücksetzen der Kamera

_CTRL + D_ zum Anzeigen/Verstecken von Debuginformationen

> manchmal müssen Tastaturbefehle länger/mehrmals gedrückt werden, um erkannt zu werden, Gründe dafür: niedrige FrameRate

- Geschwindigkeitsregler
- Pfade der Körper
- Leuchteffekt für Objekte (z.B. Sterne)
 
### Was der Code nicht kann:
- FPS-Unabhängigkeit, bei niedrigen FPS (unter 60) kam es bereits zu Problemen
  mit der Simulation.
- einfach sein... hab mir aber Mühe gegeben :)
 
### Namensgebung
- globale bzw. konstante Variablen in `ALL_CAPS`
- Datentypen/Klassen in `PascalCase`
- Funktionen und lokale Variablen in `snake_case`
  
### Wie der Code funktioniert:
#### setup:
- Physikalische Körper sowie deren Verhalten sind in der `Body`-Klasse definiert
      und werden in `BODIES` gespeichert.
- Die Körper werden in der `setup()`-Funktion definiert 
      -> alle Eigenschaften sind konstant.
#### draw
- Zunächst wird das Koordinatensystem so verschoben, dass 0,0 in der Mitte
  des Fensters liegt (+ eine Verschiebung `TRANSLATION` steuerbar durch CTRL+Maus)
- Dann wird mit `ROTATION_MATRIX = get_rotation_matrix(ROTATION);` eine neue
  Rotationsmatrix erstellt. Sie wird benötigt, um 3D-Raumkoordinaten auf den 2D-
  Bildschirm zu projezieren. Mit `project()` kann man dann diese Matrix auf ein 
  Set aus 3D-Koordinaten anwenden.
- Mit einer doppelten `ArrayList::forEach()`-Schleife übt jeder Körper auf Jeden 
  eine Kraft aus. Die Berechnung der Kraft erfolgt in `Body::apply_force()`.
- Anschließend werden ein Gitter sowie alle Körper und das Overlay (Schieberegler,
  etc.) gezeichnet.
- die Funktion beginnt von vorne.
  
