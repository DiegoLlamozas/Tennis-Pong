push = require 'push'
Class = require 'class'

require 'Player'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')

    love.window.setTitle('Tennis-Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf',16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    matchFont = love.graphics.newFont('font.ttf', 20)

    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    }

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    COURT_WIDTH = 150
    COURT_HIGHT = 200

    -- initialize the initial positions at the start of every serving
    position1 = {VIRTUAL_WIDTH/2 + COURT_WIDTH/2 - 12, VIRTUAL_HEIGHT/2 - COURT_HIGHT/2}
    position2 = {VIRTUAL_WIDTH/2 - COURT_WIDTH/2, VIRTUAL_HEIGHT/2 + COURT_HIGHT/2 - 12}


    -- Initialize both players
    player1 = Player(position1[1],position1[2],12,12,0,VIRTUAL_HEIGHT/2)
    player2 = Player(position2[1],position2[2],12,12,VIRTUAL_HEIGHT/2,VIRTUAL_HEIGHT)
    
    -- Place the Ball on the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- initialize scores variables
    player1Score = 0
    player2Score = 0

    totalMatches = 1
    currentMatch = 1

    player1Matches = 0
    player2Matches = 0

    servingPlayer = 1

    winningPlayer = 0

    PLAYER_SPEED = 200
    BALL_ACCELERATION = 3
    NUMBER_OF_PLAYERS = 2
    VICTORY_SCORE = 5

    gameState = 'startMenu'
    menuState = 'select'
end

function love.resize(w, h)
    push:resize(w,h)
end

function love.update(dt)
    if gameState == 'play' then
        if love.keyboard.isDown('w') then
            player1.dy = -PLAYER_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PLAYER_SPEED
        else
            player1.dy = 0
        end

        if love.keyboard.isDown('a') then
            player1.dx = -PLAYER_SPEED
        elseif love.keyboard.isDown('d') then
            player1.dx = PLAYER_SPEED
        else
            player1.dx = 0  -- Reset horizontal velocity to 0 when no movement keys are pressed
        end

        -- Player 2 movement
        if love.keyboard.isDown('up') then
            player2.dy = -PLAYER_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PLAYER_SPEED
        else
            player2.dy = 0
        end

        if love.keyboard.isDown('left') then
            player2.dx = -PLAYER_SPEED
        elseif love.keyboard.isDown('right') then
            player2.dx = PLAYER_SPEED
        else
            player2.dx = 0  
        end
    else
        -- Stop player 1 movement
        player1.dx = 0
        player1.dy = 0

        -- Stop player 2 movement
        player2.dx = 0
        player2.dy = 0
    end

    if gameState == 'serve' then
        ball.dx = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dy = math.random(140, 200)
        else
            ball.dy = -math.random(140, 200)
        end
    elseif gameState == 'play' then
            if ball:collides(player1) then
                ball.dy = -ball.dy * (1 + (BALL_ACCELERATION/100))
                ball.y = player1.y + 5 + player1.height
    
                -- keep velocity going in the same direction, but randomize it
                if ball.dx < 0 then
                    ball.dx = -math.random(10, 150)
                else
                    ball.dx = math.random(10, 150)
                end
    
                sounds['paddle_hit']:play()
            end

            if ball:collides(player2) then
                ball.dy = -ball.dy * (1 + (BALL_ACCELERATION/100))
                ball.y = player2.y - 5
    
                -- keep velocity going in the same direction, but randomize it
                if ball.dx < 0 then
                    ball.dx = -math.random(10, 150)
                else
                    ball.dx = math.random(10, 150)
                end
    
                sounds['paddle_hit']:play()
            end
    
            if (ball.x < VIRTUAL_WIDTH / 2 - COURT_WIDTH / 2 or ball.x > VIRTUAL_WIDTH / 2 + COURT_WIDTH / 2 or  ball.y > VIRTUAL_HEIGHT / 2 + COURT_HIGHT / 2 or ball.y < VIRTUAL_HEIGHT / 2 - COURT_HIGHT / 2) then
                if ball.y > VIRTUAL_HEIGHT / 2 then
                    if player1Score == 0 then
                        player1Score = 15
                        gameState = 'serve'
                    elseif player1Score == 15 then
                        player1Score = 30
                        gameState = 'serve'
                    elseif player1Score == 30 then
                        player1Score = 40
                        gameState = 'serve'
                    elseif player1Score == 40 then
                        player1Score = 45
                        gameState = 'serve'
                    elseif player1Score == 45 then
                        if type(player2Score) == 'number' and player2Score <= 40 then
                            player1Matches = player1Matches + 1
                            if player1Matches > totalMatches/2 then
                                winningPlayer = 1
                                gameState = 'done'
                            else
                                gameState = 'matchTransition'
                            end
                        elseif player2Score == 45 then
                            player1Score = 'adv'
                            gameState = 'serve'
                        elseif type(player2Score) == 'string' and player2Score == 'adv' then
                            player2Score = 45
                            gameState = 'serve'
                        end
                    elseif player1Score == 'adv' then
                        player1Matches = player1Matches + 1
                        if player1Matches > totalMatches/2 then
                            winningPlayer = 1
                            gameState = 'done'
                        else
                            gameState = 'matchTransition'
                        end
                    end

                    if currentMatch % 2 > 0 then
                        servingPlayer = 1
                    else
                        servingPlayer = 2
                    end

                    sounds['score']:play()
                    ball:reset()
                    
                elseif ball.y < VIRTUAL_HEIGHT / 2 then
                    if player2Score == 0 then
                        player2Score = 15
                        gameState = 'serve'
                    elseif player2Score == 15 then
                        player2Score = 30
                        gameState = 'serve'
                    elseif player2Score == 30 then
                        player2Score = 40
                        gameState = 'serve'
                    elseif player2Score == 40 then
                        player2Score = 45
                        gameState = 'serve'
                    elseif player2Score == 45 then
                        if type(player1Score) == 'number' and player1Score <= 40 then
                            player2Matches = player2Matches + 1
                            if player2Matches > totalMatches/2 then
                                winningPlayer = 2
                                gameState = 'done'
                            else
                                gameState = 'matchTransition'
                            end
                        elseif player1Score == 45 then
                            player2Score = 'adv'
                            gameState = 'serve'
                        elseif type(player1Score) == 'string' and player1Score == 'adv' then
                            player1Score = 45
                            gameState = 'serve'
                        end
                    elseif player2Score == 'adv' then
                        player2Matches = player2Matches + 1
                        if player2Matches > totalMatches/2 then
                            winningPlayer = 2
                            gameState = 'done'
                        else
                            gameState = 'matchTransition'
                        end
                    end
        

                    if currentMatch % 2 > 0 then
                        servingPlayer = 1
                    else
                        servingPlayer = 2
                    end

                    sounds['score']:play()
                    ball:reset()
                end

                if currentMatch % 2 > 0 then
                    resetPosition('keep')
                else
                    resetPosition('change')
                end
            end
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        -- the function LÖVE2D uses to quit the application
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'startMenu' then
            gameState = 'start'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'startMenu'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- reset matches
            player1Matches = 0
            player2Matches = 0

            currentMatch = 1

            resetPosition('keep')

            -- decide serving player as the opposite of who won
            if currentMatch % 2 > 0 then
                servingPlayer = 1
            else
                servingPlayer = 2
            end
        elseif gameState == 'matchTransition' then
            gameState = 'serve'

            ball:reset()

            player1Score = 0
            player2Score = 0

            currentMatch = currentMatch + 1

            if currentMatch % 2 > 0 then
                servingPlayer = 1
            else
                servingPlayer = 2
            end

            if currentMatch % 2 > 0 then
                resetPosition('keep')
            else
                resetPosition('change')
            end
        end
    elseif key == 'up' or key == 'down' then
        if gameState == 'startMenu' then
            if key == 'up' then
                if totalMatches >= 99 then
                    totalMatches = 1
                else
                    totalMatches = totalMatches + 2
                end
            elseif key == 'down' then
                if totalMatches <= 1 then
                    totalMatches = 99
                else
                    totalMatches = totalMatches - 2
                end
            end
        end
    end
end

function love.draw()

    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
       displayScore()
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'matchTransition' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Match finished!!!", 
            0, 10, VIRTUAL_WIDTH, 'center')
    end

    if gameState ~= 'startMenu' then
        drawTennisCourt()
        displayMatchScore()

        player1:render()
        player2:render()

        ball:render()
    else
        displayStartMenu()
    end

    push:apply('end')
end
function drawTennisCourt()
    -- Set court line color
    love.graphics.setColor(1, 1, 1)

    -- Draw center line within the width of the court
    love.graphics.setLineWidth(2)
    love.graphics.line(VIRTUAL_WIDTH / 2 - COURT_WIDTH / 2, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH / 2 + COURT_WIDTH / 2, VIRTUAL_HEIGHT / 2)

    -- Draw service line within the width of the court
    love.graphics.setLineWidth(2)
    love.graphics.line(VIRTUAL_WIDTH / 2 - COURT_WIDTH / 2, VIRTUAL_HEIGHT / 2 - COURT_HIGHT / 2, VIRTUAL_WIDTH / 2 + COURT_WIDTH / 2, VIRTUAL_HEIGHT / 2 - COURT_HIGHT / 2)

    -- Draw left service box
    love.graphics.rectangle('line', VIRTUAL_WIDTH / 2 - COURT_WIDTH / 2, VIRTUAL_HEIGHT / 2 - COURT_HIGHT / 2, COURT_WIDTH, COURT_HIGHT)

    -- Reset color to default
    love.graphics.setColor(1, 1, 1)
end

function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

function displayMatchScore()
    -- Set font for match score
    love.graphics.setFont(matchFont)

    -- Display player 1's match score
    love.graphics.print("Player 1: " .. tostring(player1Matches), VIRTUAL_WIDTH - 120, 20)

    -- Display player 2's match score
    love.graphics.print("Player 2: " .. tostring(player2Matches), VIRTUAL_WIDTH - 120, 50)
end

function resetPosition(type)
    if type == 'keep' then
        player1.x = position1[1]
        player1.y = position1[2]

        player2.x = position2[1]
        player2.y = position2[2]
    elseif type == 'change' then
        player1.x = position2[1]
        player1.y = position1[2]

        player2.x = position1[1]
        player2.y = position2[2]
    end
end

function displayStartMenu()
    love.graphics.setFont(scoreFont)

    love.graphics.printf('Welcome to Tennis-Pong!', 0, 10, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(largeFont)

    local matchesText = "# of Matches: " .. tostring(totalMatches)
    local matchesWidth = largeFont:getWidth(matchesText)
    love.graphics.print(matchesText, (VIRTUAL_WIDTH - matchesWidth) / 2, 40)

    love.graphics.setFont(smallFont)

    local enterText = "Press Enter to begin!"
    local enterWidth = smallFont:getWidth(enterText)
    love.graphics.print(enterText, (VIRTUAL_WIDTH - enterWidth) / 2, 60)
end
