require daslib/media
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code
let 
    HEIGHT_SCREEN = get_screen_height()
    WIDTH_SCREEN = get_screen_width()
    BACK_COLOR = 0xF0F0f0
    BRICK_COLOR = 0xFF0000
    PLAYER_COLOR = 0x0000ff
    JUMP_KEY = get_key_down(VK_SPACE)
    MOVE_RIGHT_KEY = get_key(VK_D)
    MOVE_LEFT_KEY = get_key(VK_A)

struct Rect_collider
    topLeftCorner: float2
    bottomRightCorner: float2
    collision_for_player: bool = false
    trigger: bool = false

struct Wall
    collider: Rect_collider
    color: uint
    pos: float2
    //death

struct Player
    collider: Rect_collider
    pos: float2
    velocity: float2
    speed: float
    force_jump: float = 10f
    h_col: float = 100f
    w_col: float = 100f
var
    rect_collider: Rect_collider
    player: Player
    gravity: float = 9.8*20f
    walls: array<Wall> 
    //wall: Wall
    jump_pressed: bool = false
    offsetRL: float //погрешность для боковых столкновений
    offsetDU: float //погрешность для нижн./верх. столкновений
    
def render_background()
    fill_rect(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN, BACK_COLOR)


def is_collision(var other: Rect_collider; player: Player)
    if ((player.collider.bottomRightCorner.y > other.topLeftCorner.y)
    && (player.collider.topLeftCorner.y < other.bottomRightCorner.y)
    && (player.collider.bottomRightCorner.x > other.topLeftCorner.x)
    && (player.collider.topLeftCorner.x < other.bottomRightCorner.x))
        return true;
    else
        return false;

def dir_collision(other: Rect_collider; player: Player)
    
    var down,up,right,left: bool
    var pl_col = player.collider
    //down
    if ((pl_col.bottomRightCorner.y >= other.topLeftCorner.y)
    && (pl_col.topLeftCorner.y < other.topLeftCorner.y)
    && (pl_col.topLeftCorner.x < other.bottomRightCorner.x)
    && (pl_col.bottomRightCorner.x > other.topLeftCorner.x))
        down = true
    //up
    if ((pl_col.topLeftCorner.y <= other.bottomRightCorner.y)
    && (pl_col.bottomRightCorner.y > other.bottomRightCorner.y))
        up = true
    //right
    if ((pl_col.bottomRightCorner.x >= other.topLeftCorner.x)
    && (pl_col.topLeftCorner.x < other.topLeftCorner.x)
    && (pl_col.bottomRightCorner.y > other.topLeftCorner.y+offsetRL)
    && (pl_col.topLeftCorner.y < other.bottomRightCorner.y))
        right = true
    //left
    if ((pl_col.topLeftCorner.x <= other.bottomRightCorner.x)
    && (pl_col.bottomRightCorner.x > other.bottomRightCorner.x)
    && (pl_col.bottomRightCorner.y > other.topLeftCorner.y+offsetRL)
    && (pl_col.topLeftCorner.y < other.bottomRightCorner.y))
        left = true
    var col : tuple<d:bool; u:bool; r:bool; l:bool>
    col.d = down
    col.u = up
    col.r = right
    col.l = left
    return col;

def check_collisions(var walls: array<Wall>; player: Player)
    var p_col, all_col : tuple<d:bool; u:bool; r:bool; l:bool>

    for w in walls
        if is_collision(w.collider, player)
            w.collider.collision_for_player = true
            p_col = dir_collision(w.collider, player)
            if p_col.d
                all_col.d = true
            if p_col.u
                all_col.u = true
            if p_col.r
                all_col.r = true
            if p_col.l
                all_col.l = true
        else
            w.collider.collision_for_player = false
    return all_col;

def restart_player(var player: Player)
    player.pos = float2(100,100)
    player.velocity = float2(0,0)
    player.speed = 200f
    player.force_jump = 500f
    player.h_col = 100f // выс коллайдера и спрайта
    player.w_col = 100f
    offsetRL = player.h_col / 5f
    offsetDU = player.h_col / 2f

def render_player(var player: Player)
    var height = player.collider.bottomRightCorner.y - player.collider.topLeftCorner.y
    var width = player.collider.bottomRightCorner.x - player.collider.topLeftCorner.x
    fill_rect(player.pos.x, player.pos.y, width, height, PLAYER_COLOR)

def update_player(var player: Player; dt: float)
    player.collider.topLeftCorner = player.pos
    player.collider.bottomRightCorner = player.pos+float2(player.w_col, player.h_col)
    player.pos += player.velocity*dt

    let jump = get_key(VK_SPACE)
    var p_col = check_collisions(walls, player)
    if !p_col.d
        apply_gravity(player, dt)
    else 
        if(player.velocity.y >= 0f)
            player.velocity.y = 0f
        if (jump && !jump_pressed && p_col.d && !(p_col.r || p_col.l))
            jump_player(player)
        jump_pressed = jump
    update_input(player, dt, p_col)
    //print("down   up     right  left  \n")
    //print("{p_col.d}, {p_col.u}, {p_col.r}, {p_col.l}\n")
def jump_player(var player: Player)
    player.velocity.y = clamp(player.velocity.y - player.force_jump, -1000.0, -250.0)

def apply_gravity(var player: Player; dt: float)
    player.velocity.y += gravity*dt*10f

def update_input(var player: Player; dt: float; p_col: tuple<d:bool; u:bool; r:bool; l:bool>)
    if (get_key(VK_A) && !p_col.l)
        player.velocity.x = -player.speed*dt*50f
    elif (get_key(VK_D) && !p_col.r)
        player.velocity.x = player.speed*dt*50f
    else
        player.velocity.x = 0f
        
def create_wall(var pos: float2; scale: float2; color: uint)
    var new_wall: Wall
    new_wall.color = color
    new_wall.pos = pos
    new_wall.collider.topLeftCorner = pos
    new_wall.collider.bottomRightCorner = pos + scale
    print("{length(walls)}\n")
    push(walls, new_wall)


[export]
def initialize
    set_window_title("TestPhysics1")
    restart_player(player)
    
    create_wall(float2(150, 400), float2(50, 50), 0x00000000)
    create_wall(float2(250, 200), float2(400, 300), BRICK_COLOR)
    
    create_wall(float2(50, 500), float2(1000, 220), 0xf00ff0ff)


    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
        
    update_player(player, dt)


    return

// this function will be called every frame after 'act',
// you can draw anything in this function


def render_walls(var walls: array<Wall>)
    for wall in walls
        var height = wall.collider.bottomRightCorner.y - wall.collider.topLeftCorner.y
        var width = wall.collider.bottomRightCorner.x - wall.collider.topLeftCorner.x
        wall.pos = wall.collider.topLeftCorner
        fill_rect(wall.pos.x, wall.pos.y, width, height, wall.color)
[export]
def draw
    render_background()
    render_player(player)
    render_walls(walls)
    //fill_rect(0.0, 700.0, 1280.0, 20.0, 0xffffff)
    
    return
