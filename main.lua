player = {}
numbers = {}
collectedNumbers = {}
randomNumbers = {}
numberCreationTimer = 0
numberCreationDelay = math.random(1, 2)

gameState = ""
menuOptions = {}
selectedOption = 1

function love.load()
    local flags = {
        centered = true,
        resizable = false
    }

    love.window.setTitle("square")
    love.window.setMode(800, 600, flags)
    love.graphics.setBackgroundColor(0.69, 0.89, 0.98)

    menuOptions = { "New Game", "Quit" }
    selectedOption = 1
    gameState = "menu"
end

function love.update(dt)
    if gameState == "menu" then
        if love.keyboard.isDown("up") then
            if selectedOption > 1 then
                selectedOption = selectedOption - 1
                love.timer.sleep(0.15)
            end
        elseif love.keyboard.isDown("down") then
            if selectedOption < #menuOptions then
                selectedOption = selectedOption + 1
                love.timer.sleep(0.15)
            end
        elseif love.keyboard.isDown("return") then
            if menuOptions[selectedOption] == "New Game" then
                startNewGame()
            elseif menuOptions[selectedOption] == "Quit" then
                love.event.quit()
            end
        end
    elseif gameState == "game" then
        if love.keyboard.isDown("escape") then
            gameState = "menu"
        end
        
        if love.keyboard.isDown("a") then
            player.x = player.x - (player.speed * dt)
        elseif love.keyboard.isDown("d") then
            player.x = player.x + (player.speed * dt)
        end
    
        if player.x < 0 then
            player.x = 0
        elseif player.x + player.size > love.graphics.getWidth() then
            player.x = love.graphics.getWidth() - player.size
        end
    
        if love.keyboard.isDown("w") then
            if player.speedY == 0 then
                player.speedY = player.jumpHeight
            end
        end
    
        if player.speedY ~= 0 then
            player.y = player.y + player.speedY * dt
            player.speedY = player.speedY - player.gravity * dt
        end
    
        if player.y > player.ground then
            player.speedY = 0
            player.y = player.ground
        end
    
        for i = #numbers, 1, -1 do
            local num = numbers[i]
            num.life = num.life - dt
            if num.life <= 0 then
                table.remove(numbers, i)
            elseif checkCollision(player.x, player.y, player.size, player.size, num.x, num.y, 20, 20) then
                table.insert(collectedNumbers, num.value)
                table.remove(numbers, i)
                if #collectedNumbers >= 5 then
                    gameState = "gameover"
                    compareNumbers()
                end
            end
        end
    
        numberCreationTimer = numberCreationTimer - dt
        if numberCreationTimer <= 0 then
            createRandomNumber()
            numberCreationTimer = math.random(1, 2)
        end
    elseif gameState == "gameover" then
    end
end

function love.draw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "game" then
        drawGame()
    elseif gameState == "gameover" then
        drawGameOver()
    end
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function createRandomNumber()
    local num = {
        value = math.random(1, 9),
        life = math.random(1, 5),
        x = math.random(0, love.graphics.getWidth() - 20),
        y = math.random(0, love.graphics.getHeight() - 20)
    }
    table.insert(numbers, num)
end

function drawMenu()
    love.graphics.setColor(0.91, 0.19, 0.43)
    love.graphics.printf("square", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")

    for i, option in ipairs(menuOptions) do
        local y = love.graphics.getHeight() / 2 + (i - 1) * 30
        if i == selectedOption then
            love.graphics.setColor(0.91, 0.19, 0.43)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(option, 0, y, love.graphics.getWidth(), "center")
    end
end

function drawGame()
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)

    love.graphics.setColor(1, 0, 0, 1)
    for _, num in ipairs(numbers) do
        love.graphics.print(num.value, num.x, num.y)
    end

    love.graphics.setColor(0, 0, 0, 1)
    local startX = 10
    local startY = love.graphics.getHeight() - 30
    for i, num in ipairs(collectedNumbers) do
        love.graphics.print(num, startX + (i - 1) * 20, startY)
    end

    love.graphics.setColor(0, 0, 0, 1)
    local startY2 = startY - 30
    for i, num in ipairs(randomNumbers) do
        love.graphics.print(num, startX + (i - 1) * 20, startY2)
    end
end

function drawGameOver()
    love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

function startNewGame()
    player.x = love.graphics.getWidth() / 2 - 13
    player.y = love.graphics.getHeight() - 26
    player.size = 26
    player.speed = 200
    player.ground = player.y
    player.speedY = 0
    player.jumpHeight = -400
    player.gravity = -500
    -- player.gravity > player.jumpHeight
    player.collected = {}
    collectedNumbers = {}
    numbers = {}
    randomNumbers = {}
    numberCreationTimer = 0
    numberCreationDelay = math.random(1, 2)

    for _ = 1, 5 do
        table.insert(randomNumbers, math.random(1, 9))
    end

    gameState = "game"
end

function compareNumbers()
    local match = true
    for i = 1, 5 do
        if collectedNumbers[i] ~= randomNumbers[i] then
            match = false
            break
        end
    end
    if match then
        print("You collected the correct numbers!")
        love.timer.sleep(2)
        gameState = "menu"
    else
        print("You did not collect the correct numbers.")
        love.timer.sleep(2)
        gameState = "menu"
    end
end
