/************************************************************************************\
 ____        _            ____            _                 ____  _
/ ___|  ___ | | __ _ _ __/ ___| _   _ ___| |_ ___ _ __ ___ / ___|(_)_ __ ___
\___ \ / _ \| |/ _` | '__\___ \| | | / __| __/ _ \ '_ ` _ \\___ \| | '_ ` _ \
 ___) | (_) | | (_| | |   ___) | |_| \__ \ ||  __/ | | | | |___) | | | | | | |
|____/ \___/|_|\__,_|_|  |____/ \__, |___/\__\___|_| |_| |_|____/|_|_| |_| |_|
                                |___/
                                
 SolarSystemSim - ein 3D Simultor für Gravitationskräfte zwischen Körpern
 GitHub Repository:
  - https://github.com/spydr06/solarsystemsim.git
 
 Erklärung hier oder formatiert in README.md
 
 Systemanforderungen:
  - Processing 4
 
 Was der Code kann: 
  - Simulation von Gravitationskräften zwischen (praktisch) beliebig vielen Objekten 
    (theoretisch limitiert durch das 32-Bit Integer limit von 2147483647,
     praktisch durch performance- und Speicherlimits)
  - 3D-Editorkamera und -steuerung:
      Maus zum Rotieren von X und Z Achse
      CTRL + Maus zum Verschieben des Koordinatensystems
      CTRL + R zum Zurücksetzen der Kamera
      CTRL + D zum Anzeigen/Verstecken von Debuginformationen
      -- manchmal müssen Tastaturbefehle länger/mehrmals gedrückt werden,
         um erkannt zu werden, Gründe dafür: niedrige FrameRate
  - Geschwindigkeitsregler
  - Pfade der Körper
  - Leuchteffekt für Objekte (z.B. Sterne)
 
 Was der Code (leider) nicht kann:
  - FPS-Unabhängigkeit, bei niedrigen FPS (unter 60) kam es bereits zu Problemen
    mit der Simulation.
  - einfach sein... hab mir aber Mühe gegeben :)
 
 Namensgebung
  - globale bzw. konstante Variablen in `ALL_CAPS`
  - Datentypen/Klassen in `PascalCase`
  - Funktionen und lokale Variablen in `snake_case`
  
 Wie der Code funktioniert:
  > setup:
    - Physikalische Körper sowie deren Verhalten sind in der `Body`-Klasse definiert
      und werden in `BODIES` gespeichert.
    - Die Körper werden in der `setup()`-Funktion definiert 
      -> alle Eigenschaften sind konstant.
  > draw
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
 
\**********************************************************************************/

//
// Library Imports
//

import java.util.ArrayList; // für ArrayList<T>
import java.util.Arrays;    // für Arrays.copyOf()

//
// Globale Variablen
// 

// Konstanten
public static final float DEFAULT_SCALE = 0.75f, // Standardskalierung
                          MIN_SCALE = 5f;        // kleinste Skalierung
public static final double G = 6.673e-11d; // Gravitationskonstante G
public static final String INFO_FMT = """=== DEBUG ===
fps: %d
speed: %d
scale: %f
translation: (%d|%d|%d)
rotation: (%d°|%d°|%d°)
CTRL+D zum Ausblenden
CTRL+R zum Zurücksetzen der Kamera
"""; // Formatierung der Debug-Informationen

// Simulation
public static int SPEED = 1000;      // Simulationsgeschwindigkeit
public static ArrayList<Body> BODIES = new ArrayList(); // Liste für alle Körper, die in der Simulation verwendet werden
public static float G_MULTIPLIER = 1; // Veränderung der Gravitationskonstante über den Schieberegler

// Rendering
public static PVector ROTATION = new PVector(),    // Gibt die Rotation an
                      TRANSLATION = new PVector(); // Gibt die Verschiebung an
public static Matrix ROTATION_MATRIX;              // Rotationsmatrix
public static float SCALE = DEFAULT_SCALE;         // Gibt die Skalierung an

// Eingabe
public static boolean CTRL = false, // Gibt an, ob "Steuerung" gedrückt ist
                      SHOW_DEBUG_INFO = false; // soll debug-information gezeigt werden?
public static Slider SPEED_SLIDER, // Schieberegler für die Geschwindigkeit
                     GRAVITY_SLIDER; // Schieberegler für die Gravitationskonstante
//
// Basisfunktionen
//

// setup-Funktion
public void setup() 
{
    // Öffne ein Fenster mit dem P2D renderer, da er OpenGL-basiert ist -> bessere Performance
    size(1326, 786, P2D);

    // Sonne
    BODIES.add(
      new Body(1_000_000d, 10)
        .set_color(#fcde7b)
        .set_name("Sonne")
        .glow()
    );
    
    // Merkur
    BODIES.add(
        new Body(2000, 2)
        .set_color(#808080)
        .set_name("Merkur")
        .set_position(70, 0)
        .set_velocity(0, 0.001)
    );
    
    // Venus
    BODIES.add(
        new Body(2000, 3)
        .set_color(#cfbc9f)
        .set_name("Venus")
        .set_position(0, 180)
        .set_velocity(-0.00055, 0)
    );
    
    // Erde
    BODIES.add(
        new Body(10_000, 8)
        .set_color(#9bbecf)
        .set_name("Erde")
        .set_position(300, 0)
        .set_velocity(0, 0.0005)
    );
    
    // Mond
    BODIES.add(
        new Body(10, 2)
        .set_color(#a0a0a0)
        .set_name("Mond")
        .set_position(310, 0)
        .set_velocity(0, 0.0007)
    );
    
    // Mars
    BODIES.add(
        new Body(5000)
        .set_color(#d98e77)
        .set_name("Mars")
        .set_position(600, 0)
        .set_velocity(0, 0.00034)
    );
    
    // Jupiter
    BODIES.add(
        new Body(20_000, 80)
        .set_color(#d6b77e)
        .set_name("Jupiter")
        .set_position(-2000, 0)
        .set_velocity(0, -0.00019)
    );
    
    // Saturn
    BODIES.add(
        new Body(18_000, 80)
        .set_color(#c4beb3)
        .set_name("Saturn")
        .set_position(-2800, 0, 1000)
        .set_velocity(0, -0.000145)
    );
    
    // Uranus
    BODIES.add(
        new Body(16_000, 100)
        .set_color(#baddde)
        .set_name("Uranus")
        .set_position(3500, 0, -700)
        .set_velocity(0, 0.00014)
    );
    
    // Neptun
    BODIES.add(
        new Body(17_000, 100)
        .set_color(#819fb8)
        .set_name("Neptun")
        .set_position(-4500, 0)
        .set_velocity(0, -0.00013)
    );
    
    // Pluto
    BODIES.add(
        new Body(1000, 150)
        .set_color(#e0908d)
        .set_name("Pluto")
        .set_position(0, 0, 6500)
        .set_velocity(-0.00008, 0)
    );
    
    SPEED_SLIDER = new Slider(0, 10000, SPEED, "Geschwindigkeit");
    GRAVITY_SLIDER = new Slider(0, 10, G_MULTIPLIER, "Gravitation");
}

// draw-Funktion
public void draw() 
{
    background(0); // Schwarzer Hintergrund

    // Simulation
    // ------------------------------------------------------------------

    // Setze den Ursprung des Koordinatensystems auf die Mitte des Fensters
    // und verschiebe ihn um "TRANSLATION"
    translate(width / 2 + TRANSLATION.x, height / 2 + TRANSLATION.y); 

    // Generiere eine neue Rotationsmatrix für das Rendering
    ROTATION_MATRIX = get_rotation_matrix(ROTATION);

    BODIES.forEach((a) -> // Jeder Körper erfährt eine Kraft von jedem anderen Köper
        BODIES.forEach((b) -> {
            if(a.equals(b)) // ein Körper erfährt keine Kraft von sich selbst, deswegen:
                return;     // continue;
            a.apply_force(b);
        }
    ));
      
    // Zeichne das x-y-Gitter
    grid();

    BODIES.forEach((body) -> { // Für jeden registrieten Körper:
        body.update(SPEED);    // Update und
        body.render();         // zeichne ihn
    });
    
    // Veerschiebung zurücksetzen
    translate(-width / 2 - TRANSLATION.x, -height / 2 - TRANSLATION.y); 
    
    // Overlay
    // ------------------------------------------------------------------

    SPEED_SLIDER.set_pos(width / 2 - 250, 10);
    GRAVITY_SLIDER.set_pos(width / 2 + 50, 10);
    SPEED_SLIDER.render(); // zeichne den Schieberegler 
    SPEED = (int) SPEED_SLIDER.get_value(); // aktualisiere die `SPEED`-Variable mit dem neuen Wert
    
    GRAVITY_SLIDER.render();
    G_MULTIPLIER = GRAVITY_SLIDER.get_value();   // aktualisiere `G` auf den Reglerwert, nur, wenn `USE_GRAVITY_SLIDER` gesetzt ist

    if(SHOW_DEBUG_INFO) 
    {
        fill(220); // Setze die Farbe für die FPS-Anzeige
        text(
            String.format( // formatiere den Text nach `INFO_FMT`
                INFO_FMT, (int) frameRate, (int) (frameRate * SPEED), SCALE,
                (int) TRANSLATION.x, (int) TRANSLATION.y, (int) TRANSLATION.z,
                (int) degrees(ROTATION.x), (int) degrees(ROTATION.y), (int) degrees(ROTATION.z)
            ),
        10, 20); // Zeige die FPS-Zahl an  
    }

    // Setze den Cursor
    cursor(mousePressed
      ? MOVE
      : SPEED_SLIDER.cursor_above() || GRAVITY_SLIDER.cursor_above()
        ? HAND 
        : ARROW
    );
}

//
// Hilfsfunktionen
//

// Schiebt alle Elemente eines Arrays des unbekannten Datentyps
// T um einen Index nach hinten, um platz für ein neues zu machen.
// Dabei wird das letzte Element gelöscht.
// 0, [1, 2, 3, 4, 5] -> 0, [1, 1, 2, 3, 4] -> [0, 1, 2, 3, 4]
<T> void push_back(T[] array, T value)
{
    for(int i = array.length - 1; i > 0; i--)
        array[i] = array[i - 1];
    array[0] = value;
}

<T> boolean is_last(T[] array, int index)
{
    return array.length - 1 == index || array[index + 1] == null; 
}

//
// Funktionen für das Rendering
//

// Projeziert einen 3D-Punkt (als Vektor) auf eine 2D-Fläche
// mithilfe der Rotationsmatrix
public PVector project(PVector v)
{
    return ROTATION_MATRIX
        .copy()       // kopiere die Rotationsmatrix, um sicherzugehen, dass keine Werte verändert werden
        .mult(v)      // multipliziere den Positionsvektor
        .mult(SCALE); // multipliziere mit der Skalierung
}

// Erstellt eine matrix, die 
private Matrix get_rotation_matrix(PVector r)
{
    // Ressourcen für Rotation: https://www.imatest.com/support/docs/pre-5-2/geometric-calibration-deprecated/rotations-and-translations-in-3d/
    return new Matrix(
        new float[] {
            1, 0, 0,                //         ┌ 1      0       0 ┐
            0, cos(r.x), -sin(r.x), // Rx(Θ) = │ 0 cos(Θ) -sin(Θ) │
            0, sin(r.x), cos(r.x)   //         └ 0 sin(Θ) cos(Θ)  ┘
        }
    ).mult(new Matrix(
        new float[] {
            cos(r.y), 0, sin(r.y), //         ┌ cos(Θ)  0 sin(Θ) ┐
            0, 1, 0,               // Ry(Θ) = │ 0       1      0 │
            -sin(r.y), 0, cos(r.y) //         └ -sin(Θ) 0 cos(Θ) ┘
        }
    )).mult(new Matrix(
       new float[] {               
            cos(r.z), -sin(r.z), 0, //         ┌ cos(Θ) -sin(Θ) 0 ┐
            sin(r.z), cos(r.z), 0,  // Rz(Θ) = │ sin(Θ) cos(Θ)  0 │
            0, 0, 1                 //         └ 0      0       1 ┘
        } 
    ));

    // Die drei Matrizen Rx, Ry & Rz können durch Multiplikation zusammengefasst werden
}

// Funktion um den Renderer auf Startwerte zu setzen
private void reset_renderer()
{
    ROTATION = new PVector();
    TRANSLATION = new PVector();
    SCALE = DEFAULT_SCALE;
}

// Zeichnet ein Gitter auf der x-y-Ebene
private void grid()
{
    stroke(50);
    for(int i = -10; i < 11; i++)
    {   
        PVector a = project(new PVector(10_000, i * 1000, 0));
        PVector b = project(new PVector(-10_000, i * 1000, 0));
        PVector c = project(new PVector(i * 1000, 10_000, 0));
        PVector d = project(new PVector(i * 1000, -10_000, 0));
        
        line(a.x, a.y, b.x, b.y);
        line(c.x, c.y, d.x, d.y);
    }
}

//
// Benutzereingabe (Input-Callbacks)
//

// wird ausgeführt, wenn das Mausrad gedreht wurde
public void mouseWheel(MouseEvent e)
{
    float c = e.getCount(); // gibt an, in welche Richtung das Mausrad gedreht wurde:
                            // 0: gar nicht
                            // 1: nach vorne
                            // -1: nach hinten
    SCALE += SCALE * c * 0.1; // Berechne eine neue Skalierung, relativ zur Alten
    SCALE = SCALE > MIN_SCALE ? MIN_SCALE : SCALE; // Limitiere die minimale Skalierung auf `MIN_SCALE`
}

// wird ausgeführt, wenn die Maus während dem Klicken bewegt wird
public void mouseDragged()
{
    // Wenn der Schieberegler ein Event bekommt, beende die Funktion
    if(SPEED_SLIDER.mouse_event() || GRAVITY_SLIDER.mouse_event())
        return;
    
     // Berechne die Bewegung der Maus während des letzten Frames
    int diff_x = mouseX - pmouseX;
    int diff_y = mouseY - pmouseY;
     
    if(CTRL)                             // Wenn "Steuerung" gedrückt ist, 
        TRANSLATION.add(diff_x, diff_y); // Verschiebe das Koordinatensystem
    else                                 // Ansonsten:
        ROTATION.sub(new PVector(         // Rotiere das Koordinatensystem auf X- und Z-Achse
            diff_y * 0.01,
            0,
            diff_x * 0.01
        ));
}

// wird ausgeführt, wenn eine Taste gedrückt ist
public void keyPressed() 
{
    if(key == CODED && keyCode == CONTROL) // Wenn die Taste "Steuerung" ist,
        CTRL = true;                       // setze CTRL auf true

}

// wird ausgeführt, wenn eine Taste losgelassen wird
public void keyReleased() 
{
    if(key == CODED && keyCode == CONTROL) // Wenn die Taste "Steuerung" ist,
        CTRL = false;                      // setze CTRL auf false
    
    if(!CTRL)
        return;
    switch(keyCode)
    {
    case 'R':
        reset_renderer(); // setze die Rotation, Translation und Skalierung zurück
        break;
          
    case 'D':
        SHOW_DEBUG_INFO = !SHOW_DEBUG_INFO; // zeige/verstecke Debuginformationen
        break;
    } 
}
