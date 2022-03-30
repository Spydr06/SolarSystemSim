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
public static final double SPEED = 100000d; // Simulationsgeschwindigkeit, 1 = 1 Sekunde pro Sekunde

public static double DELTA;    // gibt die Zeit seit dem letzten Frame in Millisekunden an
public static long DELTA_PREV; // cache-Variable für die Berechnung der Delta-Zeit
public static boolean FIRST_FRAME = true; // = true, wenn noch kein Frame berechnet wurde; sonst = false

public static List<Body> BODIES = new ArrayList(); // Liste für alle Körper, die in der Simulation verwendet werden

//
// Basisfunktionen
//

// setup-Funktion
void setup() 
{
    size(1080, 720);

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
}

// draw-Funktion
void draw() 
{
    background(0);                    // Schwarzer Hintergrund
    translate(width / 2, height / 2); // Setze den Ursprung des Koordinatensystems auf die Mitte des Fensters

    DELTA = get_delta_time();       // berechne die Zeit seit dem letzten Frame
    println(DELTA, TAB, frameRate); // gebe die FPS, sowie Delta-Zeit im Terminal aus

    if(!FIRST_FRAME) // Wenn der erste Frame berechnet ist, beginne die Simulation
    {
        BODIES.forEach((a) -> // Jeder Körper erfährt eine Kraft von jedem anderen Köper
            BODIES.forEach((b) -> {
                if(a.equals(b)) // ein Körper erfährt keine Kraft von sich selbst, deswegen:
                    return;     // continue;
                a.apply_force(b);
            }
        ));

        BODIES.forEach((body) -> { // Für jeden registrieten Körper:
            body.update(DELTA);    // Update und
            body.render();         // zeichne ihn
        });
    }

    FIRST_FRAME = false; // der erste Frame wurde gezeichnet
}

// Funktion zum Berechnen der Delta-Zeit
double get_delta_time() 
{
    return (
        -DELTA_PREV + (
            DELTA_PREV = this.frameRateLastNanos /* DELTA_PREV wird auf den Zeitpunkt des letzten Frames gesetzt 
                                                    (this.frameRateLastNanos wird vom PApplet bereitgestellt) */
        )     // Durch die Addition ist die Zeit in Nanosekunden zwischen den Frames bekannt
    ) / 1e9d * SPEED; // Nanosekunden zu Sekunden konvertieren
}