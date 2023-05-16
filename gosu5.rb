require 'gosu'

class GameWindow < Gosu::Window
  def initialize
    super(840, 640, false)
    self.caption = "Racing Game"
    @score = 0
    @player = Player.new(self)
    @background = Background.new(self,@score)
    @background2 = Background2.new(self)
    @obstaclepng = ['Ambulance.png','Audi.png','Black_viper.png','Mini_truck.png','Mini_van.png','Police.png','truck.png']   
    @obstacles = []
    @font = Gosu::Font.new(32) 
    @time = Time.now
  end

  def update
    # Spelaren rör sig till vänster när vänsterpilen trycks ner
    @player.move_left if Gosu::button_down?(Gosu::KB_LEFT)
    # Spelaren rör sig till höger när högerpilen trycks ner
    @player.move_right(self) if Gosu::button_down?(Gosu::KB_RIGHT)
    # Uppdatera bakgrunden
    @background.update
    @background2.update
    # Uppdatera och kolla kollisioner med varje hinder
    @obstacles.each do |obstacle|
      obstacle.update
      if @player.collides_with?(obstacle)
        puts "Score #{@score}"
        exit
      end
    end
    # Uppdatera poäng varje sekund
    if Time.now - @time >= 1
        @score += 1
        @time = Time.now
    end
    # Skapa nya hinder slumpmässigt
    if rand(100) < 2
      @obstacles.push(Obstacle.new(self, @obstaclepng))
    end
    # Uppdatera och kolla kollisioner mellan hinder
    @obstacles.each do |obstacle|
      if @player.collides_with?(obstacle)
        @score = 0
        @obstacles.clear
        break
      end
      # Ta bort hinder som har passerat fönstret
      if obstacle.y > height
        @obstacles.delete(obstacle)
      else
        obstacle.update
      end
      # Ta bort hinder som kolliderar med varandra
      @obstacles.each do |other_obstacle|
        if obstacle != other_obstacle && obstacle.collides_with?(other_obstacle)
          @obstacles.delete(obstacle)
          break
        end
      end
    end
  end
  

  def draw
    @background.draw
    @background2.draw
    @player.draw
    @obstacles.each do |obstacle|
      obstacle.draw
    end
    @font.draw("Score: #{@score}", 370, 10, 200)
  end
end

class Player
  attr_reader :x, :y

  def initialize(window)
    @image = Gosu::Image.new(window, 'car.png', false)  # Skapar en bild för spelaren
    @x = window.width / 2 - @image.width / 2  # Positionerar spelaren i mitten av fönstret horisontellt
    @y = window.height - @image.height - 10  # Positionerar spelaren nära botten av fönstret
    @speed = 5  # Spelarens hastighet
  end

  def move_left
    @x -= @speed  # Flyttar spelaren åt vänster
    @x = 0 if @x < 0  # Håller spelaren inom fönstrets vänstra kant
  end

  def move_right(window)
    @x += @speed  # Flyttar spelaren åt höger
    @x = window.width - @image.width if @x > window.width - @image.width  # Håller spelaren inom fönstrets högra kant
  end

  def collides_with?(obstacle)
    obstacle_x = obstacle.x + obstacle.width / 2  # X-position för hinder
    obstacle_y = obstacle.y + obstacle.height / 2  # Y-position för hinder
    if Gosu::distance(obstacle_x, obstacle_y, @x + @image.width / 2, @y + @image.height / 2) < 60
      return true  # Returnerar true om spelaren kolliderar med hindret
    end
    false  # Returnerar false annars
  end

  def draw
    @image.draw(@x, @y, 0)  # Ritar spelaren på skärmen
  end
end


class Background
  def initialize(window,score)
    @window = window
    @image = Gosu::Image.new(window, 'background.png', true)  # Skapar en bild för bakgrunden
    @y = 0  # Y-position för bakgrunden
    @score = score  # Poäng i spelet
  end

  def update
    @y += (5)  # Uppdaterar Y-positionen för bakgrunden (skapar en illusion av rörelse)
    @y = 0 if @y > @window.height  # Återställer Y-positionen när bakgrunden når botten av fönstret
  end

  def draw
    @image.draw(0, @y - @window.height, 0)  # Ritar bakgrunden på skärmen (över och under)
    @image.draw(0, @y, 0)
  end
end


class Background2
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(window, 'background2.png', true)
    @y = 0
  end

  def update
    # Uppdatera positionen för bakgrunden
    @y += (8)
    # Återställ positionen när bakgrunden når slutet av fönstret
    @y = 0 if @y > @window.height
  end

  def draw
    # Rita ut bakgrunden
    @image.draw(0, @y - @window.height, 0)
    @image.draw(0, @y, 0)
  end
end


class Obstacle
  attr_reader :x, :y, :width, :height

  def initialize(window, obstaclepng)
    @window = window
    # Skapa en bild för hindret genom att välja en slumpmässig bild från `obstaclepng`-arrayen
    @image = Gosu::Image.new(window, obstaclepng[rand(0...obstaclepng.length)], false)
    @width = @image.width
    @height = @image.height
    # Placera hindret slumpmässigt på x-axeln och utanför fönstret på y-axeln
    @x = rand(@window.width - @width)
    @y = -@height
    @speed = 5
  end

  def update
    # Uppdatera positionen för hindret genom att öka @y-värdet med @speed
    @y += @speed
    # Återställ positionen till startläge när hindret når slutet av fönstret
    if @y > @window.height
      @y = -@height
      @x = rand(@window.width - @width)
    end
  end

  def collides_with?(obstacle)
    obstacle_x = obstacle.x + obstacle.width / 2
    obstacle_y = obstacle.y + obstacle.height / 2
    # Kontrollera om det är en kollision mellan detta hinder och ett annat hinder
    if Gosu::distance(obstacle_x, obstacle_y, @x + @image.width / 2, @y + @image.height / 2) < 150
      return true
    end
    false
  end

  def draw
    # Rita ut hindret på dess aktuella position
    @image.draw(@x, @y, 0)
  end
end   
  

window = GameWindow.new
window.show
