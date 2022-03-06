require daslib/media
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code
let 
    HEIGHT_SCREEN = get_screen_height()
    WIDTH_SCREEN = get_screen_width()
    BACK_COLOR = 0xF0F000
    PLAYER_COLOR = 0x00FF
    JUMP_KEY = get_key_down(VK_SPACE)
    MOVE_RIGHT_KEY = get_key(VK_D)
    MOVE_LEFT_KEY = get_key(VK_A)

struct Rect_collider
    topLeftCorner: float2
    bottomRightCorner: float2
    trigger: bool = false

struct Wall
    collider: Rect_collider
    pos: float2
    //death

struct Player
    collider: Rect_collider
    pos: float2
    velocity: float2
    speed: float
    force_jump: float = 10f
var
    rect_collider: Rect_collider
    player: Player
    gravity: float = 9.8*20f
    walls: array<Wall> 
    wall: Wall
    jump_pressed: bool = false
    
// 'initialize' runs once when game starts and every hot-reload

def render_background()
    fill_rect(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN, BACK_COLOR)

def collision_down(var other: Rect_collider; player: Player)
    if (player.collider.bottomRightCorner.y > other.topLeftCorner.y)
        
        return true;//no collision
    else
        return false;
def collision_up(var other: Rect_collider; player: Player)
    if (player.collider.topLeftCorner.y < other.bottomRightCorner.y)
        
        return true;//no collision
    else
        return false;
def collision_right(var other: Rect_collider; player: Player)
    if (player.collider.bottomRightCorner.x > other.topLeftCorner.x)
        return true;//no collision
    else
        return false;
def collision_left(var other: Rect_collider; player: Player)
    if (player.collider.topLeftCorner.x < other.bottomRightCorner.x)
        return true;//no collision
    else
        return false;
def restart_player(var player: Player)
    
    player.pos = float2(110,100)
    player.velocity = float2(0,0)
    player.speed = 200f
    player.force_jump = 500f

def render_player(var player: Player)
    var height = player.collider.bottomRightCorner.y - player.collider.topLeftCorner.y
    var width = player.collider.bottomRightCorner.x - player.collider.topLeftCorner.x
    fill_rect(player.pos.x, player.pos.y, width, height, PLAYER_COLOR)

def update_player(var player: Player; dt: float)
    player.collider.topLeftCorner = player.pos
    player.collider.bottomRightCorner = player.pos+float2(100f,100f)
    player.pos += player.velocity*dt

    let jump = get_key(VK_SPACE)
    
    if !(collision_down(wall.collider, player)
        && collision_right(wall.collider, player)
        && collision_left(wall.collider, player)
        && collision_up(wall.collider, player))
        print("colliusion!")
        apply_gravity(player, dt)
    else 
        if(player.velocity.y >= 0f)
            player.velocity.y = -5f
        if (jump && !jump_pressed)
            jump_player(player)
        jump_pressed = jump
    update_input(player, dt)

def jump_player(var player: Player)
    player.velocity.y = clamp(player.velocity.y - player.force_jump, -1000.0, -250.0)

def apply_gravity(var player: Player; dt: float)
    player.velocity.y += gravity*dt*10f

def update_input(var player: Player; dt: float)
    if get_key(VK_A)
        player.velocity.x = -player.speed*dt*50f
    elif get_key(VK_D)
        player.velocity.x = player.speed*dt*50f
    else
        player.velocity.x = 0f
        
def create_wall(var wall: Wall)
    var height = wall.collider.bottomRightCorner.y - wall.collider.topLeftCorner.y
    var width = wall.collider.bottomRightCorner.x - wall.collider.topLeftCorner.x
    wall.pos = wall.collider.topLeftCorner
    fill_rect(wall.pos.x, wall.pos.y, width, height, 0x000000)

[export]
def initialize
    set_window_title("TestPhysics1")
    restart_player(player)
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

    update_player(player, dt)

    // for w in range(0, length(walls))
    //     colRect.topLeftCorner = float2(0, 50)
    //     colRect.bottomRightCorner = float2(250, 50)
    //     //print("Q")
    //     apply_gravity(player, dt)


    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    render_background()
    render_player(player)
    //fill_rect(0.0, 700.0, 1280.0, 20.0, 0xffffff)
    wall.pos = float2(200,300)
    wall.collider.topLeftCorner = wall.pos //float2(200, 300)
    wall.collider.bottomRightCorner = wall.pos+float2(400, 300)
    create_wall(wall)
    //push(walls,wall,w)
    return
