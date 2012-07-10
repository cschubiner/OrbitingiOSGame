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
        MouseState lastMouseState;
        List<Vector2> posArray;
        List<Vector2> posArrayForFrame;
        Vector2 currPosToDraw;
        SpriteFont font;
        SpriteFont biggerFont;
        string toDisplay;
        float planetScaleSize;
        KeyboardState lastKeyboardState;
        Vector2 offset;
        // the zone scale is the planet scale * this number
        float zoneScaleRelativeToPlanet;
        public Game1()
        {
            graphics = new GraphicsDeviceManager(this);
            graphics.IsFullScreen = false;
            graphics.PreferredBackBufferHeight = 720;
            graphics.PreferredBackBufferWidth = 1280;

            Window.AllowUserResizing = true;
            Content.RootDirectory = "Content";
            IsMouseVisible = true;

            zoneScaleRelativeToPlanet = 1.8f;
            planetScaleSize = .21f;
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

            posArray = new List<Vector2>();
            posArrayForFrame = new List<Vector2>();
            base.Initialize();
            currPosToDraw = Vector2.Zero;


        }

        /// <summary>
        /// LoadContent will be called once per game and is the place to load
        /// all of your content.
        /// </summary>
        protected override void LoadContent()
        {
            // Create a new SpriteBatch, which can be used to draw textures.
            spriteBatch = new SpriteBatch(GraphicsDevice);

            planetTexture = Content.Load<Texture2D>("PlanetMichael");
            zoneTexture = Content.Load<Texture2D>("zone-hd");
            frameTexture = Content.Load<Texture2D>("iphone box");
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
                MouseState mouseState = Mouse.GetState();
                KeyboardState keyboardState = Keyboard.GetState();

                if (mouseState.LeftButton == ButtonState.Released && lastMouseState.LeftButton == ButtonState.Pressed)
                {
                    Vector2 pos = new Vector2(mouseState.X - offset.X, mouseState.Y - offset.Y);
                    posArray.Add(pos);
                }

                if (mouseState.RightButton == ButtonState.Released && lastMouseState.RightButton == ButtonState.Pressed)
                {
                    Vector2 pos = new Vector2(mouseState.X - offset.X, mouseState.Y - offset.Y);
                    posArrayForFrame.Add(pos);
                }
                currPosToDraw = new Vector2(mouseState.X, mouseState.Y);

                if (keyboardState.IsKeyDown(Keys.C))
                {
                    string first = "[self CreatePlanetAndZone:";
                    string middle = " yPos:";
                    string end = "];\r\n";

                    string toCopy = "";
                    foreach (Vector2 pos in posArray)
                    {
                        toCopy += first;
                        toCopy += pos.X.ToString();
                        toCopy += middle;
                        toCopy += (graphics.GraphicsDevice.Viewport.Height - pos.Y).ToString();
                        toCopy += end;
                    }

                    StreamWriter textOut = new StreamWriter(new FileStream("output.txt", FileMode.Create, FileAccess.Write));
                    textOut.WriteLine(toCopy);
                    textOut.Close();
                }

                if (mouseState.MiddleButton == ButtonState.Released && lastMouseState.MiddleButton == ButtonState.Pressed)
                    foreach (Vector2 pos in posArray)
                    {
                        if (mouseState.X >= (pos.X + offset.X) - zoneTexture.Width * planetScaleSize * zoneScaleRelativeToPlanet / 2 && mouseState.X <= (pos.X + offset.X) + zoneTexture.Width * planetScaleSize * zoneScaleRelativeToPlanet / 2
                            && mouseState.Y >= (pos.Y + offset.Y) - zoneTexture.Height * planetScaleSize * zoneScaleRelativeToPlanet / 2 && mouseState.Y <= (pos.Y + offset.Y) + zoneTexture.Height * planetScaleSize * zoneScaleRelativeToPlanet / 2)
                        {
                            posArray.Remove(pos);
                            break;
                        }
                    }

                if (keyboardState.IsKeyDown(Keys.Z))
                    zoneScaleRelativeToPlanet += .1f * (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                else
                    planetScaleSize += .03f * (mouseState.ScrollWheelValue - lastMouseState.ScrollWheelValue) / 120;
                toDisplay = "Planet Scale (scroll to change): " + planetScaleSize.ToString() + "   Relative Zone Scale (Hold Z while scrolling): " + zoneScaleRelativeToPlanet.ToString() + "    Mouse Pos: " + (offset.X + mouseState.X).ToString() + ", " + (graphics.GraphicsDevice.Viewport.Height - (offset.Y + mouseState.Y)).ToString();

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

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.Black);
            spriteBatch.Begin();

            spriteBatch.DrawString(font, "'C' outputs code to \"output.txt\" in the exe's directory.     Right click to display iPhone's frame size.     Middle click to delete.      Arrow keys scroll.\n"+toDisplay, new Vector2(10, 
                graphics.GraphicsDevice.Viewport.Height - 45), Color.Red);

            int index= 0 ;
            foreach (Vector2 pos in posArray)
            {

                spriteBatch.Draw(zoneTexture, pos+offset, null, Color.White, 0, new Vector2(zoneTexture.Width / 2, zoneTexture.Height / 2), planetScaleSize * zoneScaleRelativeToPlanet, SpriteEffects.None, 0);
                spriteBatch.Draw(planetTexture, pos + offset, null, Color.White, 0, new Vector2(planetTexture.Width / 2, planetTexture.Height / 2), planetScaleSize, SpriteEffects.None, 0);
                spriteBatch.DrawString(biggerFont, index.ToString(), pos + offset, new Color(97,255,110));
                index++;
            }
            foreach (Vector2 pos in posArrayForFrame)
                spriteBatch.Draw(frameTexture, pos + offset, null, Color.White, 0, new Vector2(frameTexture.Width / 2, frameTexture.Height / 2), 1, SpriteEffects.None, 0);
            MouseState mouseState = Mouse.GetState();
            if (mouseState.LeftButton == ButtonState.Pressed)
            {
                spriteBatch.Draw(zoneTexture, currPosToDraw, null, Color.White, 0, new Vector2(zoneTexture.Width / 2, zoneTexture.Height / 2), planetScaleSize * zoneScaleRelativeToPlanet, SpriteEffects.None, 0);
                spriteBatch.Draw(planetTexture, currPosToDraw, null, Color.White, 0, new Vector2(planetTexture.Width/2,planetTexture.Height/2), planetScaleSize, SpriteEffects.None, 0);
            }
            if (mouseState.RightButton == ButtonState.Pressed)
                spriteBatch.Draw(frameTexture, currPosToDraw, null, Color.White, 0, new Vector2(frameTexture.Width / 2, frameTexture.Height / 2), 1, SpriteEffects.None, 0);

            spriteBatch.End();
            base.Draw(gameTime);
        }
    }
}
