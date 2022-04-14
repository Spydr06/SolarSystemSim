//
// Library Imports
//

import java.util.List;
import java.util.ArrayList;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

//
// Globale Variablen
// 

// Konstanten
public static final double G = 6.673e-11d; // Gravitations-Konstante G
public static int SPEED = 1000;            // Simulationsgeschwindigkeit, 1 = 1 Sekunde pro Sekunde (sehr langsam)

// Simulation
public static List<Body> BODIES = new ArrayList(); // Liste für alle Körper, die in der Simulation verwendet werden

// Rendering
public static PVector ROTATION = new PVector();    // Gibt die Rotation an
public static Matrix ROTATION_MATRIX;              // Rotationsmatrix
public static PVector TRANSLATION = new PVector(); // Gibt die Verschiebung an
public static float SCALE = 1;                     // Gibt die Skalierung an

// Informationen
public static String INFO_FMT = "=== DEBUG ===\nfps: %d\nspeed: %d\nscale: %f\ntranslation: (%d|%d|%d)\nrotation: (%d°|%d°|%d°)";

// Eingabe
public static boolean CTRL = false; // Gibt an, ob "Steuerung" gedrückt ist
public static Slider SPEED_SLIDER; // Schieberegler für die Geschwindigkeit

//
// Basisfunktionen
//

// setup-Funktion
public void setup() 
{
    // Öffne ein Fenster mit dem P2D renderer, da er OpenGL-basiert ist -> bessere Performance
    size(1326, 786, P2D);

    // Die Sonne in der Mitte
    BODIES.add(
      new Body(1_000_000d)
        .set_color(#ffd232)
        .set_name("Sonne")
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
        new Body(20_000)
        .set_color(#d6b77e)
        .set_name("Jupiter")
        .set_position(-2000, 0)
        .set_velocity(0, -0.00019)
    );
    
    // Saturn
    BODIES.add(
        new Body(18_000)
        .set_color(#c4beb3)
        .set_name("Saturn")
        .set_position(-2800, 0, 1000)
        .set_velocity(0, -0.000145)
    );
    
    // Uranus
    BODIES.add(
        new Body(16_000)
        .set_color(#baddde)
        .set_name("Uranus")
        .set_position(3500, 0, -700)
        .set_velocity(0, 0.00014)
    );
    
    // Neptun
    BODIES.add(
        new Body(17_000)
        .set_color(#819fb8)
        .set_name("Neptun")
        .set_position(-4500, 0)
        .set_velocity(0, -0.0001)
    );
    
    // Pluto
    BODIES.add(
        new Body(1000, 100)
        .set_color(#e0908d)
        .set_name("Pluto")
        .set_position(0, 0, 6500)
        .set_velocity(-0.000065, 0)
    );
    
    SPEED_SLIDER = new Slider(200, 20, 0, 10000, SPEED, "Geschwindigkeit");
}

// draw-Funktion
public void draw() 
{
    background(0); // Schwarzer Hintergrund
    fill(255);     // Setze die Farbe für die FPS-Anzeige
    text(
        String.format(
            INFO_FMT, (int) frameRate, (int) (frameRate * SPEED), SCALE,
            (int) TRANSLATION.x, (int) TRANSLATION.y, (int) TRANSLATION.z,
            (int) degrees(ROTATION.x), (int) degrees(ROTATION.y), (int) degrees(ROTATION.z)
        ),
    10, 20); // Zeige die FPS-Zahl an
    
    SPEED_SLIDER.render(); // zeichne den Schieberegler 
    SPEED = SPEED_SLIDER.get_value(); // aktualisiere die "SPEED"-Variable mit dem neuen Wert

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
}

//
// Hilfsfunktionen
//

// Schiebt alle Elemente eines Arrays des unbekannten Datentyps
// T um einen Index nach hinten, um platz für ein neues zu machen.
// Dabei wird das letzte Element gelöscht.
<T> void push_back(T[] array, T value)
{
    for(int i = array.length - 1; i > 0; i--)
        array[i] = array[i - 1];
    array[0] = value;
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

    // Die drei Matrizen Rx,Ry & Rz können durch Multiplikation zusammengefasst werden
}

// Funktion um den Renderer auf Startwerte zu setzen
private void reset_renderer()
{
    ROTATION = new PVector();
    TRANSLATION = new PVector();
    SCALE = 1;
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
// Benutzereingabe
//

// wird ausgeführt, wenn das Mausrad gedreht wurde
public void mouseWheel(MouseEvent e)
{
    float c = e.getCount(); // gibt an, in welche Richtung das Mausrad gedreht wurde:
                            // 0: gar nicht
                            // 1: nach vorne
                            // -1: nach hinten
    SCALE += SCALE * c * 0.1; // Berechne eine neue Skalierung, relativ zur Alten
}

// wird ausgeführt, wenn die Maus während dem Clicken bewegt wird
public void mouseDragged()
{
     if(SPEED_SLIDER.mouse_event())
         return;
  
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
public void keyPressed() {
    if(key == CODED && keyCode == CONTROL) // Wenn die Taste "Steuerung" ist,
        CTRL = true;                       // setze CTRL auf true
    if(keyCode == 'R')    // Wenn 'R' gedrückt ist,
        reset_renderer(); // setze die Rotation, Translation und Skalierung zurück
}

// wird ausgeführt, wenn eine Taste losgelassen wird
public void keyReleased() {
    if(key == CODED && keyCode == CONTROL) // Wenn die Taste "Steuerung" ist,
        CTRL = false;                      // setze CTRL auf false
}