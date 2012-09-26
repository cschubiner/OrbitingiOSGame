using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;
using System.IO;
using System.Text.RegularExpressions;

namespace Level_Creator
{
    /// <summary>
    /// This is the main type for your game
    /// </summary>
    public class Game1 : Microsoft.Xna.Framework.Game
    {
        GraphicsDeviceManager graphics;
        SpriteBatch spriteBatch;
        Texture2D planetTexture;
        Texture2D zoneTexture;
        Texture2D frameTexture;
        Texture2D asteroidTexture;
        Texture2D coinTexture;
        Texture2D powerupTexture;
        MouseState lastMouseState;

        public struct posScaleStruct
        {
            public Vector2 pos;
            public float scale;
            public int powerupType;
            public float rotation;
        }

        List<posScaleStruct> posArray;
        List<posScaleStruct> posArrayForFrame;
        List<posScaleStruct> posArrayAsteroid;
        List<posScaleStruct> posArrayCoin;
        List<posScaleStruct> posArrayPowerups;
        Vector2 currPosToDraw;
        SpriteFont font;
        SpriteFont biggerFont;
        string toDisplay;
        float whereToDisplayFirstErrorMessageY;
        const float defaultPlanetScaleSize = 1;
        const float minPlanetScale = 1;
        const float defaultAsteroidScaleSize = 1;// .87552f;
        const float defaultCoinScaleSize = 1;
        const float minAsteroidScale = .875f;
       // const float asteroidScaleFactorForScalingInGame = 1.0f / .87552f;//defaultAsteroidScaleSize;
        const float defaultPowerupScaleSize = 1.1f;
        float currentRotation;
        int currentPowerupType;
        float currentAsteroidScale;
        float currentPlanetScale;
        float currentFrameScale;
        float currentZoneScale;
        bool thereIsAnError;
        float currentCoinScale;
        KeyboardState lastKeyboardState;
        Vector2 offset;
        float timeSinceOutput;
        // the zone scale is the planet scale * this number
        const float defaultZoneScaleRelativeToPlanet = 1.7f;
        public Game1()
        {
            graphics = new GraphicsDeviceManager(this);
            graphics.IsFullScreen = false;
            graphics.PreferredBackBufferHeight = 720;
            graphics.PreferredBackBufferWidth = 1280;

            Window.AllowUserResizing = true;
            Content.RootDirectory = "Content";
            IsMouseVisible = true;

        }

        /// <summary>
        /// Allows the game to perform any initialization it needs to before starting to run.
        /// This is where it can query for any required services and load any non-graphic
        /// related content.  Calling base.Initialize will enumerate through any components
        /// and initialize them as well.
        /// </summary>
        protected override void Initialize()
        {
            // TODO: Add your initialization logic here

            posArray = new List<posScaleStruct>();
            posArrayAsteroid = new List<posScaleStruct>();
            posArrayCoin = new List<posScaleStruct>();
            posArrayForFrame = new List<posScaleStruct>();
            posArrayPowerups = new List<posScaleStruct>();
            currentPowerupType = 0;
            timeSinceOutput = 11000;
            currentRotation = 0;
            base.Initialize();
            currPosToDraw = Vector2.Zero;
            currentFrameScale = 1;
            currentAsteroidScale = defaultAsteroidScaleSize;
            currentPlanetScale = defaultPlanetScaleSize;
            currentZoneScale = defaultZoneScaleRelativeToPlanet;
            currentCoinScale = defaultCoinScaleSize;
          
        }

        /// <summary>
        /// LoadContent will be called once per game and is the place to load
        /// all of your content.
        /// </summary>
        protected override void LoadContent()
        {
            // Create a new SpriteBatch, which can be used to draw textures.
            spriteBatch = new SpriteBatch(GraphicsDevice);
            asteroidTexture  = Content.Load<Texture2D>("asteroidsmall");
            planetTexture = Content.Load<Texture2D>("planet2small");
            coinTexture = Content.Load<Texture2D>("coin");
            zoneTexture = Content.Load<Texture2D>("zonesmall");
            frameTexture = Content.Load<Texture2D>("iphone box");
            powerupTexture = Content.Load<Texture2D>("asteroidbreakercoinsmall");
            // TODO: use this.Content to load your game content here
            lastMouseState = Mouse.GetState();  
            lastKeyboardState = Keyboard.GetState();
            offset = Vector2.Zero;

            font = Content.Load<SpriteFont>("font");
            biggerFont = Content.Load<SpriteFont>("biggerFont");
        }

        /// <summary>
        /// UnloadContent will be called once per game and is the place to unload
        /// all content.
        /// </summary>
        protected override void UnloadContent()
        {
            // TODO: Unload any non ContentManager content here
        }

        /// <summary>
        /// Allows the game to run logic such as updating the world,
        /// checking for collisions, gathering input, and playing audio.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Update(GameTime gameTime)
        {
            // Allows the game to exit
            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed)
                this.Exit();
            if (this.IsActive)
            {
                timeSinceOutput += gameTime.ElapsedGameTime.Milliseconds;
                MouseState mouseState = Mouse.GetState();
                KeyboardState keyboardState = Keyboard.GetState();
                if (mouseState.LeftButton == ButtonState.Released && lastMouseState.LeftButton == ButtonState.Pressed)
                {
                    posScaleStruct pstruct = new posScaleStruct();
                    pstruct.pos = new Vector2(mouseState.X - offset.X, mouseState.Y - offset.Y);
                    pstruct.scale = currentPlanetScale;
                    currentPlanetScale = defaultPlanetScaleSize;
                    posArray.Add(pstruct);
                }

                if ((mouseState.RightButton == ButtonState.Pressed && lastMouseState.RightButton == ButtonState.Released)||
                    (keyboardState.IsKeyDown(Keys.A) && lastKeyboardState.IsKeyUp(Keys.A)))
                    currentAsteroidScale = defaultAsteroidScaleSize;

                if (keyboardState.IsKeyDown(Keys.F)&&lastKeyboardState.IsKeyUp(Keys.F))
                    currentFrameScale = 1;

                if (keyboardState.IsKeyUp(Keys.F) && lastKeyboardState.IsKeyDown(Keys.F))
                {
                    posScaleStruct pstruct = new posScaleStruct();
                    pstruct.pos = new Vector2(mouseState.X - offset.X, mouseState.Y - offset.Y);
                    pstruct.scale = currentFrameScale;
                    pstruct.rotation = currentRotation;
                    posArrayForFrame.Add(pstruct);
                }

                if ((mouseState.RightButton == ButtonState.Released && lastMouseState.RightButton == ButtonState.Pressed) ||
                    (keyboardState.IsKeyUp(Keys.A) && lastKeyboardState.IsKeyDown(Keys.A)))
                {
                    posScaleStruct pstruct = new posScaleStruct();
                    pstruct.pos = new Vector2(mouseState.X - offset.X, mouseState.Y - offset.Y);
                    pstruct.scale = currentAsteroidScale;
                    posArrayAsteroid.Add(pstruct);
                }
                if (keyboardState.IsKeyUp(Keys.C) && lastKeyboardState.IsKeyDown(Keys.C))
                {
                    posScaleStruct pstruct = new posScaleStruct();
                    pstruct.pos = new Vector2(mouseState.X - offset.X, mouseState.Y - offset.Y);
                    pstruct.scale = currentCoinScale;
                    posArrayCoin.Add(pstruct);
                }
                if (keyboardState.IsKeyUp(Keys.P) && lastKeyboardState.IsKeyDown(Keys.P))
                {
                    posScaleStruct pstruct = new posScaleStruct();
                    pstruct.pos = new Vector2(mouseState.X - offset.X, mouseState.Y - offset.Y);
                    pstruct.scale = currentPowerupType;
                    posArrayPowerups.Add(pstruct);
                }
                currPosToDraw = new Vector2(mouseState.X, mouseState.Y);

                if (keyboardState.IsKeyDown(Keys.L) && lastKeyboardState.IsKeyUp(Keys.L))
                {
                    string[] parts = { "", "" };
                    try
                    {
                        string levelText = System.IO.File.ReadAllText(@"input.txt");
                        char[] delimiterChars = { ' ', ',', '(',')',':',']'};

                        string[] words = levelText.Split(delimiterChars);
                        System.Console.WriteLine("{0} words in text:", words.Length);

                        foreach (string s in words)
                        {
                         //   System.Console.WriteLine(s);
                        }

                        string[] lines = Regex.Split(levelText, "\r\n");

                        foreach (string line in lines)
                        {
                           // Console.WriteLine(line);
                        }

                        parts = levelText.Split(new string[] {"],", "\r\n","[[LevelObjectReturner alloc]initWithType:" ,"  position:ccp(",",",") scale:"}, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string line in parts)
                        {
                            Console.WriteLine(line);
                        }
                    }
                    catch { }
                        for (int i = 2; i < parts.Length; i += 4)
                        {
                            try
                            {
                                posScaleStruct newStruct = new posScaleStruct();
                                string typeText = parts[i];
                                Console.WriteLine(typeText);
                                string xPos = parts[i + 1];
                                string yPos = parts[i + 2];
                                string scale = parts[i + 3];
                                Console.WriteLine(xPos);
                                newStruct.pos = new Vector2((float)Convert.ToDouble(xPos), -(float)Convert.ToDouble(yPos));
                                newStruct.scale = (float)Convert.ToDouble(scale);
                                if (typeText == "kpowerup")
                                    posArrayPowerups.Add(newStruct);
                                if (typeText == "kasteroid")
                                {
                                    if (Math.Abs(1 - newStruct.scale) <= .000001)
                                        newStruct.scale = 1;
                                    posArrayAsteroid.Add(newStruct);
                                }
                                if (typeText == "kcoin")
                                    posArrayCoin.Add(newStruct);
                                if (typeText == "kplanet")
                                    posArray.Add(newStruct);
                            }
                            catch { }
                        }
                        timeSinceOutput = 0;
                }
                if (keyboardState.IsKeyDown(Keys.O) && lastKeyboardState.IsKeyUp(Keys.O))
                {
                    //[[LevelObjectReturner alloc]initWithType:kplanet position:ccp(0,0) scale:1],

                    string first = "[[LevelObjectReturner alloc]initWithType:";
                    string middle = "  position:ccp(";
                    string middle2 = ") scale:";
                    string end = "],";

                    float xOffset = 0;
                    float yOffset = 0;
                    // create reader & open file
                    try
                    {
                        string[] lines = System.IO.File.ReadAllLines(@"offset.txt");

                        // read a line of text
                        xOffset = int.Parse(lines[0]);
                        yOffset = int.Parse(lines[1]);
                    }
                    catch {}

                    string toCopy = "";
                    Vector2 firstPlanetPos = Vector2.Zero;
                    try
                    {
                    firstPlanetPos = posArray[0].pos;
                    }
                    catch { }
                    foreach (posScaleStruct pstruct in posArrayPowerups)
                    {
                        toCopy += first;
                        toCopy += "kpowerup";
                        toCopy += middle;
                        toCopy += (pstruct.pos.X - firstPlanetPos.X + xOffset).ToString() + "," + (-((pstruct.pos.Y - yOffset) - firstPlanetPos.Y)).ToString();
                        toCopy += middle2;
                        toCopy += pstruct.scale.ToString();
                        toCopy += end;
                    }
                    foreach (posScaleStruct pstruct in posArrayAsteroid)
                    {
                        toCopy += first;
                        toCopy += "kasteroid";
                        toCopy += middle;
                        toCopy += (pstruct.pos.X - firstPlanetPos.X + xOffset).ToString() + "," + (-((pstruct.pos.Y - yOffset) - firstPlanetPos.Y)).ToString();
                        toCopy += middle2;
                        toCopy += (pstruct.scale).ToString();
                        toCopy += end;
                    }

                 //   toCopy += "\r\n\r\n";
                    foreach (posScaleStruct pstruct in posArrayCoin)
                    {
                        toCopy += first;
                        toCopy += "kcoin";
                        toCopy += middle;
                        toCopy += (pstruct.pos.X - firstPlanetPos.X + xOffset).ToString() + "," + (-((pstruct.pos.Y - yOffset) - firstPlanetPos.Y)).ToString();
                        toCopy += middle2;
                        toCopy += pstruct.scale.ToString();
                        toCopy += end;
                    }

                    // toCopy += "\r\n\r\n";
                    foreach (posScaleStruct pstruct in posArray)
                    {
                        toCopy += first;
                        toCopy += "kplanet";
                        toCopy += middle;
                        toCopy += (pstruct.pos.X - firstPlanetPos.X + xOffset).ToString() + "," + (-((pstruct.pos.Y - yOffset) - firstPlanetPos.Y)).ToString();
                        toCopy += middle2;
                        toCopy += pstruct.scale.ToString();
                        toCopy += end;
                    }
                    
                    StreamWriter textOut = new StreamWriter(new FileStream("output.txt", FileMode.Create, FileAccess.Write));
                    textOut.WriteLine("//Level Title: PUT_TITLE_HERE Difficulty: PUT_DIFFICULTY_HERE_(OUT OF TEN)\r\n[NSArray arrayWithObjects: "+ toCopy + " nil], //end of level segment");
                    textOut.Close();

                    first = "[self CreatePlanetAndZone:";
                    middle = " yPos:";
                    middle2 = " scale:";
                    end = "];\r\n";

                    toCopy = "";
                    foreach (posScaleStruct pstruct in posArray)
                    {
                        toCopy += first;
                        toCopy += (pstruct.pos.X + xOffset).ToString();
                        toCopy += middle;
                        toCopy += (graphics.GraphicsDevice.Viewport.Height - pstruct.pos.Y + yOffset).ToString();
                        toCopy += middle2;
                        toCopy += pstruct.scale.ToString();
                        toCopy += end;
                    }

                    toCopy += "\r\n\r\n";
                    first = "[self CreateAsteroid:";
                    foreach (posScaleStruct pstruct in posArrayAsteroid)
                    {
                        toCopy += first;
                        toCopy += (pstruct.pos.X + xOffset).ToString();
                        toCopy += middle;
                        toCopy += (graphics.GraphicsDevice.Viewport.Height - pstruct.pos.Y + yOffset).ToString();
                        toCopy += middle2;
                        toCopy += (pstruct.scale).ToString();
                        toCopy += end;
                    }

                    first = "[self CreatePowerup:";
                    foreach (posScaleStruct pstruct in posArrayPowerups)
                    {
                        toCopy += first;
                        toCopy += (pstruct.pos.X + xOffset).ToString();
                        toCopy += middle;
                        toCopy += (graphics.GraphicsDevice.Viewport.Height - pstruct.pos.Y + yOffset).ToString();
                        toCopy += middle2;
                        toCopy += defaultPowerupScaleSize.ToString();
                        toCopy += " type:";
                        toCopy += pstruct.scale.ToString();
                        toCopy += end;
                    }

                    toCopy += "\r\n\r\n";
                    first = "[self CreateCoin:";
                    foreach (posScaleStruct pstruct in posArrayCoin)
                    {
                        toCopy += first;
                        toCopy += (pstruct.pos.X + xOffset).ToString();
                        toCopy += middle;
                        toCopy += (graphics.GraphicsDevice.Viewport.Height - pstruct.pos.Y + yOffset).ToString();
                        toCopy += middle2;
                        toCopy += pstruct.scale.ToString();
                        toCopy += end;
                    }

                    textOut = new StreamWriter(new FileStream("outputOld.txt", FileMode.Create, FileAccess.Write));
                    textOut.WriteLine(toCopy);
                    textOut.Close();
                    timeSinceOutput = 0 ;
                }

                if (mouseState.MiddleButton == ButtonState.Released && lastMouseState.MiddleButton == ButtonState.Pressed
                    || (keyboardState.IsKeyDown(Keys.D) && lastKeyboardState.IsKeyUp(Keys.D)))
                {
                    foreach (posScaleStruct pstruct in posArray)
                    {
                        Vector2 pos = pstruct.pos;
                        if (mouseState.X >= (pos.X + offset.X) - zoneTexture.Width * pstruct.scale / 2 && mouseState.X <= (pos.X + offset.X) + zoneTexture.Width * pstruct.scale / 2
                            && mouseState.Y >= (pos.Y + offset.Y) - zoneTexture.Height * pstruct.scale / 2 && mouseState.Y <= (pos.Y + offset.Y) + zoneTexture.Height * pstruct.scale / 2)
                        {
                            posArray.Remove(pstruct);
                            break;
                        }
                    }

                    foreach (posScaleStruct pstruct in posArrayAsteroid)
                    {
                        Vector2 pos = pstruct.pos;
                        if (mouseState.X >= (pos.X + offset.X) - asteroidTexture.Width * pstruct.scale / 2 && mouseState.X <= (pos.X + offset.X) + asteroidTexture.Width * pstruct.scale / 2
                            && mouseState.Y >= (pos.Y + offset.Y) - asteroidTexture.Height * pstruct.scale / 2 && mouseState.Y <= (pos.Y + offset.Y) + asteroidTexture.Height * pstruct.scale / 2)
                        {
                            posArrayAsteroid.Remove(pstruct);
                            break;
                        }
                    }

                    foreach (posScaleStruct pstruct in posArrayPowerups)
                    {
                        Vector2 pos = pstruct.pos;
                        if (mouseState.X >= (pos.X + offset.X) - powerupTexture.Width * defaultPowerupScaleSize / 2 && mouseState.X <= (pos.X + offset.X) + powerupTexture.Width * defaultPowerupScaleSize / 2
                            && mouseState.Y >= (pos.Y + offset.Y) - powerupTexture.Height * defaultPowerupScaleSize / 2 && mouseState.Y <= (pos.Y + offset.Y) + powerupTexture.Height * defaultPowerupScaleSize / 2)
                        {
                            posArrayPowerups.Remove(pstruct);
                            break;
                        }
                    }

                    foreach (posScaleStruct pstruct in posArrayCoin)
                    {
                        Vector2 pos = pstruct.pos;
                        if (mouseState.X >= (pos.X + offset.X) - coinTexture.Width * pstruct.scale / 2 && mouseState.X <= (pos.X + offset.X) + coinTexture.Width * pstruct.scale / 2
                            && mouseState.Y >= (pos.Y + offset.Y) - coinTexture.Height * pstruct.scale / 2 && mouseState.Y <= (pos.Y + offset.Y) + coinTexture.Height * pstruct.scale / 2)
                        {
                            posArrayCoin.Remove(pstruct);
                            break;
                        }
                    }
                }
                if (keyboardState.IsKeyDown(Keys.R))
                    currentRotation += .6f*.75f*.05f*(mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                else if (keyboardState.IsKeyDown(Keys.Z))
                    currentZoneScale += .1f * (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                else if (keyboardState.IsKeyDown(Keys.F))
                    currentFrameScale += .06f * (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                else if (mouseState.LeftButton == ButtonState.Pressed )
                    currentPlanetScale += .03f * (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                else if (keyboardState.IsKeyDown(Keys.C))
                    currentCoinScale += .023f * (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                else if (mouseState.RightButton == ButtonState.Pressed ||keyboardState.IsKeyDown(Keys.A))
                    currentAsteroidScale += .023f * (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                else if (keyboardState.IsKeyDown(Keys.P))
                    currentPowerupType += (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue)/120;

                if (currentPlanetScale < minPlanetScale) currentPlanetScale = minPlanetScale;
                if (currentAsteroidScale < minAsteroidScale) currentAsteroidScale = minAsteroidScale;
                if (currentPowerupType < 0) currentPowerupType = 0;
                if (currentPowerupType > 2) currentPowerupType = 2;
                string powerupTypeString;
                if (currentPowerupType == 0)
                    powerupTypeString = "Random";
                else if (currentPowerupType == 1)
                    powerupTypeString = "Asteroid Armor";
                else if (currentPowerupType == 2)
                    powerupTypeString = "Star Magnet";
                else powerupTypeString = "INVALID POWERUP TYPE";
                toDisplay = "Planet Scale: " + currentPlanetScale.ToString() + "   Relative Zone Scale: " + 
                    currentZoneScale.ToString() + "    Mouse Pos: " + (offset.X + mouseState.X).ToString() + ", " + (graphics.GraphicsDevice.Viewport.Height - (offset.Y + mouseState.Y)).ToString()
                    + "   Zoom scale: " + (1 / currentFrameScale).ToString() + "     Asteroid Scale: " + currentAsteroidScale.ToString()
                    + "     Powerup Type: " + powerupTypeString +"("+currentPowerupType.ToString()+")";

                if (posArray.Count > 1)
                    toDisplay += "     Last Planet Distance: " + getDistanceBetweenLastPlanets().ToString();

                int offsetPixels = 200;
                if (keyboardState.IsKeyDown(Keys.Up) && lastKeyboardState.IsKeyUp(Keys.Up))
                {
                    offset.Y += offsetPixels;
                }
                if (keyboardState.IsKeyDown(Keys.Down) && lastKeyboardState.IsKeyUp(Keys.Down))
                {
                    offset.Y += -offsetPixels;
                }
                if (keyboardState.IsKeyDown(Keys.Left) && lastKeyboardState.IsKeyUp(Keys.Left))
                {
                    offset.X += offsetPixels;
                }
                if (keyboardState.IsKeyDown(Keys.Right) && lastKeyboardState.IsKeyUp(Keys.Right))
                {
                    offset.X += -offsetPixels;
                }

                lastKeyboardState = keyboardState;
                lastMouseState = mouseState;
                base.Update(gameTime);
            }
        }

        private float getDistanceBetweenLastPlanets()
        {
            return (posArray[posArray.Count - 2].pos - posArray[posArray.Count - 1].pos).Length();
        }


        public float UnsignedAngleBetweenTwoV3(Vector3 v1, Vector3 v2)
        {
            v1.Normalize();
            v2.Normalize();
            double Angle = (float)Math.Acos(Vector3.Dot(v1, v2));
            return (float)(180*Angle/Math.PI);
        }

        public bool angleBetweenThreePointsIsTooBig(Vector2 v1, Vector2 v2, Vector2 v3)
        {
            Vector3 v31 = new Vector3(v2 - v1, 0);
            Vector3 v32 = new Vector3(v3 - v2, 0);
            return UnsignedAngleBetweenTwoV3(v31, v32) > 55;
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime)
        {
            if (timeSinceOutput < 150)
            {
                if (thereIsAnError==false)
                GraphicsDevice.Clear(new Color(51, 255, 0));
                else
                    GraphicsDevice.Clear(new Color(255, 0, 0));
            }
            else
                GraphicsDevice.Clear(Color.Black);
            spriteBatch.Begin();

            spriteBatch.DrawString(font, "'P'= Powerup (scroll changes type).     'A' = Asteroid      'C' = Coin      'D' = Delete      'L' = Load (from input.txt)      'R' = Rotate\n'O' outputs code to \"output.txt\" in the exe's directory.     'F' displays iPhone's frame size.     Middle click to delete.      Arrow keys scroll.\n" + toDisplay, new Vector2(10, 
                graphics.GraphicsDevice.Viewport.Height - 65), Color.Red);

            whereToDisplayFirstErrorMessageY = 80;
            thereIsAnError = false;


            if (posArray.Count > 7)
                displayMessage(false, "There are more than 7 planets placed.");

            try
            {
                int index1 = 0;
                foreach (posScaleStruct pstruct in posArray)
                {
                    Vector2 pos = pstruct.pos;
                    if (angleBetweenThreePointsIsTooBig(pos, posArray[index1 + 1].pos, posArray[index1 + 2].pos))
                        displayMessage(false, "The angle between some of the planets is probably too big.");
                    index1++;
                }
            }
            catch { }


            try
            {
            bool stuffLeftOfFirstPlanet = false;
            bool stuffRightOfLastPlanet = false;
            bool coinNotScaleOne = false;


            if (posArrayPowerups.Count > 2)
                displayMessage(false, "There are more than two powerups placed");
            if (posArrayForFrame.Count < 1)
                displayMessage(false, "There are no frames placed. Use frames (the 'f' key) to align flight paths and hold 'r' simultaneously and scroll to rotate.");
            if (getDistanceBetweenLastPlanets() < 352.0f)
                displayMessage(false, "The distance between the last two placed planets is probably too small.");
            if (getDistanceBetweenLastPlanets() > 935.0f)
                displayMessage(false, "The distance between the last two placed planets is probably too big.");
            
            foreach (posScaleStruct pstruct in posArrayCoin)
            {
                if (pstruct.pos.X < posArray[0].pos.X - zoneTexture.Width / 2 * defaultZoneScaleRelativeToPlanet)
                    stuffLeftOfFirstPlanet = true;
                if (pstruct.pos.X > posArray[posArray.Count - 1].pos.X+zoneTexture.Width/2*defaultZoneScaleRelativeToPlanet)
                    stuffRightOfLastPlanet = true;

                if (coinNotScaleOne == false)
                    if (Math.Abs(pstruct.scale - 1) > .05)
                        coinNotScaleOne = true;
            }
            if (coinNotScaleOne)
                displayMessage(false, "Not all coins placed have a scale of 1.");

            if (Math.Abs(posArray[0].scale - 1) > .05f)
                displayMessage(true, "The first planet's scale is not 1.");
            if (Math.Abs(posArray[posArray.Count - 1].scale - 1) > .05)
                displayMessage(true, "The last planet's scale is not 1.");

            foreach (posScaleStruct pstruct in posArrayAsteroid)
            {
                if (pstruct.pos.X+asteroidTexture.Width/2*pstruct.scale < posArray[0].pos.X)
                    stuffLeftOfFirstPlanet = true;
                if (pstruct.pos.X - asteroidTexture.Width / 2 * pstruct.scale > posArray[posArray.Count - 1].pos.X)
                    stuffRightOfLastPlanet = true;
            }
            if (stuffLeftOfFirstPlanet == false || stuffRightOfLastPlanet ==false)
             foreach (posScaleStruct pstruct in posArrayAsteroid)
            {
                if (pstruct.pos.X < posArray[0].pos.X)
                    stuffLeftOfFirstPlanet = true;
                if (pstruct.pos.X > posArray[posArray.Count - 1].pos.X)
                    stuffRightOfLastPlanet = true;
            }
            if (stuffLeftOfFirstPlanet == false || stuffRightOfLastPlanet == false)
            foreach (posScaleStruct pstruct in posArrayPowerups)
            {
                if (pstruct.pos.X < posArray[0].pos.X)
                    stuffLeftOfFirstPlanet = true;
                if (pstruct.pos.X > posArray[posArray.Count - 1].pos.X)
                    stuffRightOfLastPlanet = true;
            }
            if (stuffLeftOfFirstPlanet == false || stuffRightOfLastPlanet == false)
           

            if (stuffLeftOfFirstPlanet)
                displayMessage(true, "Objects are placed before the first planet");
            if (stuffRightOfLastPlanet)
                displayMessage(true, "Objects are placed after the last planet");
            
             for (int i = 1; i < posArray.Count; i++) {
                 if (posArray[i].pos.X < posArray[i - 1].pos.X) {
                     displayMessage(true, "The planets do not go from left to right.");
                     break;
                 }
             }
          
            }
            catch { }

            if (posArray.Count < 5)
                displayMessage(true, "There are less than 5 planets placed.");

            int index = 0;
            foreach (posScaleStruct pstruct in posArray)
            {
                Vector2 pos = pstruct.pos;
                spriteBatch.Draw(zoneTexture, pos+offset, null, Color.White, 0, new Vector2(zoneTexture.Width / 2, zoneTexture.Height / 2), pstruct.scale * defaultZoneScaleRelativeToPlanet, SpriteEffects.None, 0);
                spriteBatch.Draw(planetTexture, pos + offset, null, Color.White, 0, new Vector2(planetTexture.Width / 2, planetTexture.Height / 2), pstruct.scale, SpriteEffects.None, 0);
                DrawHelperString(index, pos, pstruct.scale);
                index++;
            }
            index = 0;
            foreach (posScaleStruct pstruct in posArrayAsteroid)
            {
                Vector2 pos = pstruct.pos;
                spriteBatch.Draw(asteroidTexture, pos + offset, null, Color.White, 0, new Vector2(asteroidTexture.Width / 2, asteroidTexture.Height / 2), pstruct.scale, SpriteEffects.None, 0);
                DrawHelperString(index, pos, pstruct.scale);
                index++;
            }
            index = 0;
            foreach (posScaleStruct pstruct in posArrayPowerups)
            {
                Vector2 pos = pstruct.pos;
                spriteBatch.Draw(powerupTexture, pos + offset, null, Color.White, 0, new Vector2(powerupTexture.Width / 2, powerupTexture.Height / 2), defaultPowerupScaleSize, SpriteEffects.None, 0);
                DrawHelperString(index, pos, pstruct.scale);
                index++;
            }
            index = 0;
            foreach (posScaleStruct pstruct in posArrayCoin)
            {
                Vector2 pos = pstruct.pos;
                spriteBatch.Draw(coinTexture, pos + offset, null, Color.White, 0, new Vector2(coinTexture.Width / 2, coinTexture.Height / 2), pstruct.scale, SpriteEffects.None, 0);
                DrawHelperString(index, pos, pstruct.scale);
                index++;
            }

            foreach (posScaleStruct pstruct in posArrayForFrame)
                spriteBatch.Draw(frameTexture, pstruct.pos + offset, null, Color.White, pstruct.rotation, new Vector2(frameTexture.Width / 2, frameTexture.Height / 2), pstruct.scale, SpriteEffects.None, 0);
            MouseState mouseState = Mouse.GetState();
            KeyboardState keyboardState = Keyboard.GetState();
            if (mouseState.LeftButton == ButtonState.Pressed)
            {
                spriteBatch.Draw(zoneTexture, currPosToDraw, null, Color.White, 0, new Vector2(zoneTexture.Width / 2, zoneTexture.Height / 2), currentPlanetScale * defaultZoneScaleRelativeToPlanet, SpriteEffects.None, 0);
                spriteBatch.Draw(planetTexture, currPosToDraw, null, Color.White, 0, new Vector2(planetTexture.Width / 2, planetTexture.Height / 2), currentPlanetScale, SpriteEffects.None, 0);
            }
            if (keyboardState.IsKeyDown(Keys.F))
                spriteBatch.Draw(frameTexture, currPosToDraw, null, Color.White, currentRotation, new Vector2(frameTexture.Width / 2, frameTexture.Height / 2), currentFrameScale, SpriteEffects.None, 0);
            if (mouseState.RightButton == ButtonState.Pressed||keyboardState.IsKeyDown(Keys.A))
                spriteBatch.Draw(asteroidTexture, currPosToDraw, null, Color.White, 0, new Vector2(asteroidTexture.Width / 2, asteroidTexture.Height / 2), currentAsteroidScale, SpriteEffects.None, 0);
            if (keyboardState.IsKeyDown(Keys.C))
                spriteBatch.Draw(coinTexture, currPosToDraw, null, Color.White, 0, new Vector2(coinTexture.Width / 2, coinTexture.Height / 2), currentCoinScale, SpriteEffects.None, 0);
            if (keyboardState.IsKeyDown(Keys.P))
                spriteBatch.Draw(powerupTexture, currPosToDraw, null, Color.White, 0, new Vector2(powerupTexture.Width / 2, powerupTexture.Height / 2), defaultPowerupScaleSize, SpriteEffects.None, 0);
            
            spriteBatch.End();
            base.Draw(gameTime);
        }

        private void displayMessage(bool isError, string message)
        {
            if (isError)
                thereIsAnError = true;
            string initialText = "Warning: ";
            Color color = Color.Yellow;
            if (isError)
            {
                initialText = "ERROR: ";
                color = Color.Red;
            }
            spriteBatch.DrawString(font, initialText + message, new Vector2(20, whereToDisplayFirstErrorMessageY), color);
            whereToDisplayFirstErrorMessageY += 22;
        }

        private Vector2 DrawHelperString(int index, Vector2 pos, float scale)
        {
            spriteBatch.DrawString(biggerFont, index.ToString(), pos + offset + new Vector2(0, -15), new Color(97, 255, 110));
            spriteBatch.DrawString(biggerFont, scale.ToString(), pos + offset + new Vector2(0, 15), new Color(0, 110, 255));
            return pos;
        }
    }
}