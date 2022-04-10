//
// Library Imports
//

import java.util.List;
import java.util.ArrayList;

//
// Globale Variablen
// 

// Konstanten
public static final double G = 6.673e-11d; // Gravitations-Konstante G
public static final double SPEED = 1000;   // Simulationsgeschwindigkeit, 1 = 1 Sekunde pro Sekunde (sehr langsam)

// Simulation
public static List<Body> BODIES = new ArrayList(); // Liste für alle Körper, die in der Simulation verwendet werden

// Rendering
public static PVector ROTATION = new PVector();    // Gibt die Rotation an
public static Matrix ROTATION_MATRIX;              // Rotationsmatrix
public static PVector TRANSLATION = new PVector(); // Gibt die Verschiebung an
public static float SCALE = 1;                     // Gibt die Skalierung an

// Informationen
public static String INFO_FMT = "fps: %d\nspeed: %d\nscale: %f\ntranslation: (%d|%d|%d)\nrotation: (%d°|%d°|%d°)";

// Eingabe
public static boolean CTRL = false; // Gibt an, ob "Steuerung" gedrückt ist

//
// Basisfunktionen
//

// setup-Funktion
void setup() 
{
    // Öffne ein Fenster mit dem P2D renderer, da er OpenGL-basiert ist -> bessere Performance
    size(1326, 786, P2D);

    // Die Sonne in der Mitte
    BODIES.add(
      new Body(1_000_000d)
        .set_color(#ffe000)
        .set_name("Sonne")
    );

    // Erde
    BODIES.add(
        new Body(10_000d)
        .set_position(-200, 0)
        .set_velocity(0, 0.0005)
        .set_color(#00a0ff)
        .set_name("Erde")
    );

    // Mond um die Erde
    BODIES.add(
        new Body(1d)
        .set_position(-190, 0)
        .set_velocity(0, 0.0007)
        .set_color(#505050)
        .set_name("Mond")
    );
    
    // Mars
    BODIES.add(
        new Body(10_000d)
        .set_position(0, 0, 350)
        .set_velocity(0, 0.0004)
        .set_color(#ff8800)
        .set_name("Mars")
    );
}

// draw-Funktion
void draw() 
{
    background(0);                        // Schwarzer Hintergrund
    fill(255); // Setze die Farbe für die FPS-Anzeige: weiß > 30, rot <= 30, da bei niedrigen FPS-Zahlen die Simulation nich richtig funktionieren könnte
    text(
        String.format(
            INFO_FMT, (int) frameRate, (int) (frameRate * SPEED), SCALE,
            (int) TRANSLATION.x, (int) TRANSLATION.y, (int) TRANSLATION.z,
            (int) degrees(ROTATION.x), (int) degrees(ROTATION.y), (int) degrees(ROTATION.z)
        ),
    10, 20);               // Zeige die FPS-Zahl an

    // Setze den Ursprung des Koordinatensystems auf die Mitte des Fensters
    // und verschiebe ihn um TRANSLATION
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
      
    // Zeichne 3 linien vom Ursprung aus, um das Koordinatensystem zu verdeutlichen
    PVector a = project(new PVector(100, 0, 0)); // Berechne die 2D-Koordinaten
    PVector b = project(new PVector(0, 100, 0));
    PVector c = project(new PVector(0, 0, 100));
    
    stroke(#ff0000);      // Rot für die
    line(0, 0, a.x, a.y); // X-Koordinate
    stroke(#00ff00);      // Grün für die
    line(0, 0, b.x, b.y); // Y-Koordinate
    stroke(#0000ff);      // Blau für die
    line(0, 0, c.x, c.y); // Z-Koordinate

    BODIES.forEach((body) -> { // Für jeden registrieten Körper:
        body.update(SPEED);    // Update und
        body.render();         // zeichne ihn
    });
}

//
// Funktionen für das Rendering
//

// Projeziert einen 3D-Punkt (als Vektor) auf eine 2D-Fläche
// mithilfe der Rotationsmatrix
PVector project(PVector v)
{
    return ROTATION_MATRIX
        .copy()       // kopiere die Rotationsmatrix, um sicherzugehen, dass keine Werte verändert werden
        .mult(v)      // multipliziere den Positionsvektop
        .mult(SCALE); // multipliziere mit der Skalierung
}

// Erstellt eine matrix, die 
Matrix get_rotation_matrix(PVector r)
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

    // Die drei Matrizen Rx,Ry & Rz können durch Multiplikation zusammengefasst werden
}

// Funktion um den Renderer auf Startwerte zu setzen
void reset_renderer()
{
    ROTATION = new PVector();
    TRANSLATION = new PVector();
    SCALE = 1;
}

//
// Benutzereingabe
//

// wird ausgeführt, wenn das Mausrad gedreht wurde
void mouseWheel(MouseEvent e)
{
    float c = e.getCount(); // gibt an, in welche Richtung das Mausrad gedreht wurde:
                            // 0: gar nicht
                            // 1: nach vorne
                            // -1: nach hinten
    SCALE += SCALE * c * 0.1; // Berechne eine neue Skalierung, relativ zur Alten
}

// wird ausgeführt, wenn die Maus während dem Clicken bewegt wird
void mouseDragged()
{
     int diff_x = mouseX - pmouseX; // Berechne die Bewegung der Maus im letzten Frame
     int diff_y = mouseY - pmouseY; // Berechne die Bewegung der Maus im letzten Frame
     
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
void keyPressed() {
    if(key == CODED && keyCode == CONTROL) // Wenn die Taste "Steuerung" ist,
        CTRL = true;                       // setze CTRL auf true
    if(keyCode == 'R')    // Wenn 'R' gedrückt ist,
        reset_renderer(); // setze die Rotation, Translation und Skalierung zurück
}

// wird ausgeführt, wenn eine Taste losgelassen wird
void keyReleased() {
    if(key == CODED && keyCode == CONTROL) // Wenn die Taste "Steuerung" ist,
        CTRL = false;                      // setze CTRL auf false
}
