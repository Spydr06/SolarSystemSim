//
// Library Imports
//

import java.util.List;
import java.util.ArrayList;
//import java.javafx.*;

//
// Globale Variablen
// 

// Konstanten
public static final double G = 6.673e-11d; // Gravitations-Konstante G
public static final double SPEED = 1000;   // Simulationsgeschwindigkeit, 1 = 1 Sekunde pro Sekunde (sehr langsam)

public static List<Body> BODIES = new ArrayList(); // Liste für alle Körper, die in der Simulation verwendet werden
public static PVector ROTATION = new PVector();
public static PVector TRANSLATION = new PVector();
public static float SCALE = 1;
public static boolean CTRL = false;

//
// Basisfunktionen
//

// setup-Funktion
void setup() 
{
    size(1326, 786, P2D);

    BODIES.add(
      new Body(1_000_000d)
        .set_color(#ffe000)
        .set_name("Sonne")
    );

    BODIES.add(
        new Body(10_000d)
        .set_position(-200, 0)
        .set_velocity(0, 0.0005)
        .set_color(#00a0ff)
        .set_name("Erde")
    );

    BODIES.add(
        new Body(1d)
        .set_position(-190, 0)
        .set_velocity(0, 0.0007)
        .set_color(#505050)
        .set_name("Mond")
    );
    
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
    text((int) frameRate, 0, 10);               // Zeige die FPS-Zahl an

    translate(width / 2 + TRANSLATION.x, height / 2 + TRANSLATION.y); // Setze den Ursprung des Koordinatensystems auf die Mitte des Fensters

    BODIES.forEach((a) -> // Jeder Körper erfährt eine Kraft von jedem anderen Köper
        BODIES.forEach((b) -> {
            if(a.equals(b)) // ein Körper erfährt keine Kraft von sich selbst, deswegen:
                 return;     // continue;
            a.apply_force(b);
        }
    ));

    BODIES.forEach((body) -> { // Für jeden registrieten Körper:
        body.update(SPEED);    // Update und
        body.render();         // zeichne ihn
    });
    
    PVector a = project(new PVector(100, 0, 0));
    PVector b = project(new PVector(0, 100, 0));
    PVector c = project(new PVector(0, 0, 100));
    
    stroke(255, 0, 0);
    line(0, 0, a.x, a.y);
    stroke(0, 255, 0);
    line(0, 0, b.x, b.y);
    stroke(0, 0, 255);
    line(0, 0, c.x, c.y);
}

PVector project(PVector in)
{
    return new PVector(
        cos(ROTATION.y) * -in.z + sin(ROTATION.y) * -in.x, 
        
        -in.y - sin(ROTATION.y) * in.z + cos(ROTATION.y) * in.x, 
        0
    ).mult(SCALE);
}

void mouseWheel(MouseEvent e)
{
    float c = e.getCount();
    SCALE += c * 0.1;
    if(SCALE < 0) 
        SCALE = 0;
}

void mouseDragged()
{
     int diff_x = mouseX - pmouseX;
     int diff_y = mouseY - pmouseY;
     
     if(CTRL)
     {
         TRANSLATION.add(diff_x, diff_y);
     }
     else
         ROTATION.y -= diff_x * 0.01;
}

void keyPressed() {
    if(key == CODED && keyCode == CONTROL)
        CTRL = true;
}

void keyReleased() {
    if(key == CODED && keyCode == CONTROL)
        CTRL = false;
}
