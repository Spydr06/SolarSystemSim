// Klasse, die einen Körper darstellt
class Body 
{
    //
    // Konstanten
    //
    
    private static final int NUM_TRAIL_ELEMENTS = 100,     // Gibt an, wie viele Elemente (Punkte) ein Pfad hat
                             DEFAULT_TRAIL_ROUGHNESS = 10, // Standardwert für die Grobheit des Pfades
                             GLOW_SIZE = 120;              // Größe des Leuchteffekts
    
    //
    // Variablen
    //

    private PVector pos = new PVector(), // die Position des Körpers
                    vel = new PVector(), // die Geschwindigkeit des Körpers
                    acc = new PVector(); // die Beschleunigung des Körpers
    private double mass; // die Masse des Körpers

    private String name = "";    // Name des Körpers
    private color col = #ffffff; // die Farbe, mit der der Körper gezeichnet wird
    private PGraphics glow;      // Ein vorgerendertes Bild für den Leuchteffekt 

    private PVector[] trail = new PVector[NUM_TRAIL_ELEMENTS]; // Array, das die letzten Positionen des Planteten speichert
    private long trail_roughness = DEFAULT_TRAIL_ROUGHNESS;    // Grobheit des Pfades (grob -> lang aber ungenau <> fein -> kurz aber genau)
                                                               // (genauer gesagt der Abstand zwischen dem letzten Pfadpunkt und der Position)
    //
    // Konstruktor
    //

    public Body(double mass) 
    {
        this.mass = mass;
    }

    public Body(double mass, long trail_roughness)
    {
        this.mass = mass;
        this.trail_roughness = trail_roughness;    
    }

    //
    // Basisfunktionen
    //

    // Funktion zum Aktualisieren der Parameter eines Körpers
    public void update(double speed)
    {
        this.vel.add(this.acc.copy().mult((float) speed)); // Die Beschleunigung multipliziert mit der Zeit ergibt die Geschwindigkeit
        this.pos.add(this.vel.copy().mult((float) speed)); // Die Geschwindigkeit multipliziert mit der Zeit ergibt die neue Position

        this.acc.set(0, 0, 0); // setze die Beschleunigung zurück

        // Wenn der Körper sich weit genug bewegt hat (oder kein Pfad vorhanden ist (trail[0] == null)),
        // schiebe alle Elemente des Pfades um einen Index nach hinten und füge die aktuelle Position
        // als neues Element 0 hinzu.
        if(this.trail[0] == null || this.pos.dist(this.trail[0]) > this.trail_roughness)
            push_back(this.trail, this.pos.copy());
    }

    // Funktion zum Zeichnen eines Körpers
    public void render() 
    {
        PVector draw_pos = project(this.pos);                         // Projeziere die aktuelle 3d-Position auf das 2d-Fenster   
        PVector xy = project(new PVector(this.pos.x, this.pos.y, 0)); // Punkt auf der XY-Ebene, mit den gleichen XY-Koordinaten (für die Höhenlinie)

        // Zeichne die Höhenlinie (position auf x, y, 0)
        stroke(50);
        line(draw_pos.x, draw_pos.y, xy.x, xy.y);

        // Zeichne den Pfad
        noFill();
        stroke(this.col, 100); // Normalerweise hat der Pfad einen Alphawert von 100 (etwas transparent -> 255 = solide, 0 = unsichtbar)            
        strokeWeight(2);       // Liniendicke auf 2px
        beginShape();          // Beginne eine Form (Linie) aus Punkten
        vertex(draw_pos.x, draw_pos.y); // Erster Punkt auf der aktuellen Position
        
        // Füge einen Punkt zur aktuellen PShape (begonnen mit beginShape()) für jedes Element im Pfad-array hinzu
        for(int i = 0; i < this.trail.length && this.trail[i] != null; i++)
        {
            PVector trail_draw_pos = project(this.trail[i]);
            if(is_last(this.trail, i))
                stroke(this.col, 0);
    
            vertex(trail_draw_pos.x, trail_draw_pos.y);
        }
        endShape(); // Beende die Form
        strokeWeight(1); // Liniendicke auf 1px
      
        // Zeichne den Körper selbst
        // Setze die korrekte Farbe
        stroke(this.col);
        fill(this.col);
        
        // wenn der Körper leuchten soll, zeichne das vorgerenderte Bild an den korrekten Koordinaten
        if(this.glow != null)
            image(this.glow, draw_pos.x - this.glow.width / 2, draw_pos.y - this.glow.height / 2);
        circle(draw_pos.x, draw_pos.y, 5); // Zeichne einen Kreis an den aktuellen Koordinaten
        
        if(!this.name.equals("")) // Wenn ein Name gesetzt ist, zeichne auch diesen
            text(this.name, draw_pos.x + 10, draw_pos.y + 10);
    }

    public void apply_force(Body b)
    {
        // Berechne die Gewichtskraft g für die aktuelle Situation
        double g = (
            b.get_mass() / 
            pow(this.pos.dist(b.get_pos()), 2)
        ) * G * G_MULTIPLIER;

        // Berechne die Kraft, die auf den Körper wirkt
        double F = this.mass * g;

        PVector AB = b.get_pos().sub(this.pos); // Ein Vektor von diesem Körper zu b
        PVector F_AB = AB.mult((float) F / sqrt(pow(AB.x, 2) + pow(AB.y, 2) + pow(AB.z, 2))); // Wende die Kraft F auf diesen Körper in Richtung des Körpers b an

        this.acc.add(F_AB.div((float) this.mass)); // Beschleunige den Körper
    }
      
    // Zeichnet einen Leuchteffekt in ein Bild (PImage entspricht PGraphics),
    // welcher später in der render() methode verwendet werden kann.
    // Der effekt wird hier aus Performancegründen vorgerendert.
    public Body glow() {        
        if(this.glow != null) // wenn es schon einen Effekt gibt,
            return this;      // Beende die Funktion
            
        this.glow = createGraphics(GLOW_SIZE, GLOW_SIZE); // Ansonsten erstelle eine neue PGraphics-Instanz
        this.glow.beginDraw(); // Beginne den Zeichenmodus
            
        // setze die korrekte Farbe
        this.glow.fill(this.col);
        this.glow.stroke(this.col);
        
        // 1. Render-vorgang
        this.glow.circle(this.glow.width / 2, this.glow.height / 2, 40);
        this.glow.filter(BLUR, 20);
        
        // 2. Render-vorgang (bessere Ergebnisse)
        this.glow.circle(this.glow.width / 2, this.glow.height / 2, 20);
        this.glow.filter(BLUR, 10);
        
        this.glow.endDraw(); // Beende den Zeichenmodus
        return this;
    }

    //
    // Setter
    // Setter geben die Instanz der Klasse zurück, damit Setter-Funktionen aneinander gereiht werden können:
    // z.B.: new Body(1).set_velocity(10, 0).set_position(0, 0).set_name("Körper 1")
    //

    // Setzt die Beschleunigung
    public Body set_velocity(float vx, float vy)
    {
        this.vel.set(vx, vy);
        return this;
    }

    // Setzt die Position
    public Body set_position(float x, float y)
    {
        this.pos.set(x, y);
        return this;
    }
    
    public Body set_position(float x, float y, float z)
    {
        this.pos.set(x, y, z);
        return this;
    }

    // Setzt den Namen
    public Body set_name(String name) 
    {
        this.name = new String(name);
        return this;
    }

    // Setzt die Farbe
    public Body set_color(color col) 
    {
        this.col = col;
        return this;
    }

    //
    // Getter
    //

    // Gibt die Masse des Körpers zurück
    public double get_mass()
    {
        return this.mass;
    }

    // Gibt die Position zurück
    public PVector get_pos()
    {
        return this.pos.copy();
    }
}
