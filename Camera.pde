class Camera 
{
    //
    // Variablen
    //

    private PVector pos = new PVector(0, 0, 0);
    private PVector rot = new PVector(PI / 6, 0, 0);

    //
    // Konstruktor
    //

    public Camera() 
    {

    }

    //
    // Basisfunktionen
    //

    public void update() 
    {

    }

    public void apply_perspective()
    {
        rotateX(rot.x);
        rotateY(rot.y);
        rotateZ(rot.z);
        translate(pos.x, pos.y, pos.z);
        
    }

    public void reset()
    {
        pos = new PVector(0, 0, 0);
        rot = new PVector(PI / 6, 0, 0);
    }

    //
    // Getter
    //

    public Camera set_scale(float scale)
    {
        this.pos.z = scale;
        return this;
    }

    public Camera set_position(PVector pos)
    {
        this.pos = pos.get();
        return this;
    }

    public Camera set_rotation(PVector rot)
    {
        this.rot = rot.get();
        return this;
    }

    //
    // Setter
    //

    public float get_scale()
    {
        return this.pos.z;
    }

    public PVector get_position()
    {
        return this.pos;
    }

    public PVector get_rotation()
    {
        return this.rot;
    }
}