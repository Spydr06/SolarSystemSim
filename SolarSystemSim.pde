//
// Library Imports
//

import java.util.List;
import java.util.ArrayList;

//
// Globale Variablen
// 

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
        new Body(1000)
        .set_velocity(10, 0)
        .set_name("Sonne")
    );

    BODIES.add(
        new Body(1)
        .set_position(-100, 0)
        .set_name("Erde")
    );
}

// draw-Funktion
void draw() 
{
    background(0);
    translate(width / 2, height / 2);

    DELTA = get_delta_time(); // berechne die Zeit seit dem letzten Frame
    println(DELTA, TAB, frameRate);

    if(!FIRST_FRAME) // Wenn der erste Frame berechnet ist, beginne die Simulation
        BODIES.forEach((body) -> { // Für jeden registrieten Körper,
            body.update(DELTA);    // update und
            body.render();         // zeichne ihn
        });

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
    ) / 1e9d; // Nanosekunden zu Sekunden konvertieren
}