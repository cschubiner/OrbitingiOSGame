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
        Texture2D frameTexture;
        MouseState lastMouseState;
        List<Vector2> posArray;
        List<Vector2> posArrayForFrame;
        Vector2 currPosToDraw;
        SpriteFont font;
        string toDisplay;

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
            frameTexture = Content.Load<Texture2D>("iphone box");
            // TODO: use this.Content to load your game content here
            lastMouseState = Mouse.GetState();

            font = Content.Load<SpriteFont>("font");
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

            MouseState mouseState = Mouse.GetState();
            if (mouseState.LeftButton == ButtonState.Released && lastMouseState.LeftButton == ButtonState.Pressed)
            {
                Vector2 pos = new Vector2(mouseState.X, mouseState.Y);
                posArray.Add(pos);
            }

            if (mouseState.RightButton == ButtonState.Released && lastMouseState.RightButton == ButtonState.Pressed)
            {
                Vector2 pos = new Vector2(mouseState.X, mouseState.Y);
                posArrayForFrame.Add(pos);
            }

                currPosToDraw = new Vector2(mouseState.X, mouseState.Y);


            if (Keyboard.GetState().IsKeyDown(Keys.C))
            {
                string first = "        [self CreatePlanetAndZone:";
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


            toDisplay = mouseState.X.ToString() + ", " + (graphics.GraphicsDevice.Viewport.Height - mouseState.Y).ToString();

            lastMouseState = mouseState;
            base.Update(gameTime);
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.CornflowerBlue);
            spriteBatch.Begin();

            spriteBatch.DrawString(font, "'C' outputs code to \"output.txt\" in the exe's directory. Right click to display iPhone's frame size. Mouse Pos: "+toDisplay, new Vector2(10, 
                graphics.GraphicsDevice.Viewport.Height - 25), Color.Red);

            float planetScaleSize = .21f;

            foreach (Vector2 pos in posArray)
                spriteBatch.Draw(planetTexture, pos, null, Color.White, 0, pos, planetScaleSize, SpriteEffects.None, 0);
            foreach (Vector2 pos in posArrayForFrame)
                spriteBatch.Draw(frameTexture, pos, Color.White);

            MouseState mouseState = Mouse.GetState();
            if (mouseState.LeftButton == ButtonState.Pressed)
                spriteBatch.Draw(planetTexture, currPosToDraw, null, Color.White, 0, currPosToDraw, planetScaleSize, SpriteEffects.None, 0);
            if (mouseState.RightButton == ButtonState.Pressed)
                spriteBatch.Draw(frameTexture, currPosToDraw, Color.White);

            spriteBatch.End();
            base.Draw(gameTime);
        }
    }
}
