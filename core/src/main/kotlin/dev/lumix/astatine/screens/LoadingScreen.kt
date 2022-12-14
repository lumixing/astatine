package dev.lumix.astatine.screens

import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.g2d.BitmapFont
import dev.lumix.astatine.Astatine
import dev.lumix.astatine.engine.Static
import dev.lumix.astatine.engine.SoundAssets
import dev.lumix.astatine.engine.TextureAtlasAssets
import dev.lumix.astatine.engine.load
import ktx.app.KtxScreen
import ktx.freetype.loadFreeTypeFont
import ktx.freetype.registerFreeTypeFontLoaders

class LoadingScreen(private val game: Astatine) : KtxScreen {
    override fun render(delta: Float) {
        Static.assets.update()
        Static.camera.update()

//        Static.batch.use { batch ->
//            if (!Static.assets.isFinished) {
//                Static.font.draw(batch, "loading assets...", 1280f/2f, 720f/2f)
//            }
//        }

        if (Static.assets.isFinished) {
            Static.font = Static.assets.get<BitmapFont>("hack.ttf")
            game.addScreen(MainScreen())
            game.setScreen<MainScreen>()
            game.removeScreen<LoadingScreen>()
            dispose()
        }
    }

    override fun show() {
        SoundAssets.values().forEach { Static.assets.load(it) }
        TextureAtlasAssets.values().forEach { Static.assets.load(it) }
        Static.assets.registerFreeTypeFontLoaders()
        Static.assets.loadFreeTypeFont("hack.ttf") {
            size = 14
            color = Color.WHITE
            borderColor = Color.BLACK
            borderWidth = 1.3f
        }
    }
}