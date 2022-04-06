// Klasse, die einen Körper darstellt
class Body 
{
    //
    // Variablen
    //

    private PVector pos; // die Position des Körpers
    private PVector vel; // die Geschwindigkeit des Körpers
    private PVector acc; // die Beschleunigung des Körpers
    private double mass; // die Masse des Körpers

    private String name = "";    // Name des Körpers
    private color col = #ffffff; // die Farbe, mit der der Körper gezeichnet wird

    //
    // Konstruktor
    //

    public Body(double mass) 
    {
        this.mass = mass;
        this.pos = new PVector();
        this.vel = new PVector();
        this.acc = new PVector();
    }

    //
    // Basisfunktionen
    //

    // Funktion zum Aktualisieren der Parameter eines Körpers
    public void update(double delta)
    {
        this.vel.add(this.acc.copy().mult((float) delta)); // Die Beschleunigung multipliziert mit der Zeit ergibt die Geschwindigkeit
        this.pos.add(this.vel.copy().mult((float) delta)); // Die Geschwindigkeit multipliziert mit der Zeit ergibt die neue Position

        this.acc.set(0, 0, 0); // setze die Beschleunigung zurück
    }

    // Funktion zum Zeichnen eines Körpers
    public void render() 
    {
        // Setze die Farbe
        stroke(this.col);
        fill(this.col);

        PVector draw_pos = project(this.pos);
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
        ) * G;

        // Berechne die Kraft, die auf den Körper wirkt
        double F = this.mass * g;

        PVector AB = b.get_pos().sub(this.pos); // Ein Vektor von diesem Körper zu b
        PVector F_AB = AB.mult((float) F / sqrt(pow(AB.x, 2) + pow(AB.y, 2) + pow(AB.z, 2))); // Wende die Kraft F auf diesen Körper in Richtung des Körpers b an

        this.acc.add(F_AB.div((float) this.mass)); // Beschleunige den Körper
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
