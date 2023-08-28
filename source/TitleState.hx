package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var startedIntro:Bool = false;
	var skippedIntro:Bool = false;
    var introPhase:Int = 0;
	var black:FlxSprite = null;
    var pressText:FlxSprite;
    var creepy:FlxSprite;
	var titleTextColors:Array<FlxColor> = [0xFF5F0909, 0xFF901515];
	var titleTextAlphas:Array<Float> = [1, .64];
	static public var soundExt:String = ".ogg";
	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	#if TITLE_SCREEN_EASTER_EGG
	var easterEggKeys:Array<String> = [
		'SHADOW', 'RIVER', 'SHUBS', 'BBPANZU'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();


		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		pressText = new FlxSprite(100, FlxG.height * 0.8);
		pressText.frames = FlxAtlasFrames.fromSparrow('assets/images/titleEnter.png', 'assets/images/titleEnter.xml');
		pressText.animation.addByPrefix('idle', "ENTER IDLE", 24);
		pressText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		pressText.antialiasing = true;
		pressText.animation.play('idle');
		pressText.updateHitbox();
		pressText.alpha = 0.0001;
		pressText.active = false;
		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();


		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'rhodes_w');

		ClientPrefs.loadPrefs();


		Highscore.load();

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			if (initialized){
				startedIntro = true;
				startIntro();
				
			}
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startedIntro = true;
					startIntro();
					
				});
			}
		}
		#end
	}


	function startIntro()
	{
		if (!initialized)
		{
			/**/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		black = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		black.scrollFactor.set();
		black.alpha = 0;
	
		FlxG.camera.flash(0xFF000000, 2, null, true);
		
		chains = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/chains.png');
		chains.screenCenter();
		chains.scale.set(0.9, 0.9);
		chains.alpha = 0.5;
		chains.scrollFactor.set();
		add(chains);

		intro1 = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/warningImage1.png');
		intro1.screenCenter();
		intro1.scale.set(0.48, 0.48);
		intro1.scrollFactor.set();
		add(intro1);

		add(pressText);
		// credGroup.add(credTextShit);
	}



	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG
		if (!pressedEnter && skippedIntro)
		{
			var timer:Float = titleTimer;
			if (timer >= 1)
				timer = (-timer) + 2;
			
			timer = FlxEase.quadInOut(timer);
			
			pressText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
			pressText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
		}
		if (startedIntro && !skippedIntro && !transitioning)
			{
				if (pressedEnter && introPhase < 4)
				{
					introPhase += 1;
					FlxG.camera.flash(0xFF000000, 1.5, null, true);
					FlxG.sound.play('assets/sounds/confirmMenuintro' + TitleState.soundExt, 0.7);
					startRealIntro();
					pressedEnter = false;
				}
			}

			if (pressedEnter && introPhase == 4)
				{
					//:saxe_mafalda: lol
					introPhase += 1;
					FlxG.sound.play('assets/sounds/confirmMenuintro' + TitleState.soundExt, 0.7);
					add(black);
					FlxTween.tween(black, {alpha: 1}, 2.2, {
						onComplete: function(twn) 
						{
							skipIntro();
						}
					});
					pressedEnter = false;
				}

				if (startedIntro && skippedIntro && pressedEnter && !transitioning)
					{
						pressText.color = FlxColor.WHITE;
						pressText.alpha = 1;
						pressText.animation.play('press');
						FlxG.camera.flash(0xFFffffff, 1, null, true);
						if (!initialized)
						{
							initialized = true;
							FlxG.sound.music.fadeOut(1.95);
						}
						FlxG.sound.play('assets/sounds/confirmMenuintro' + TitleState.soundExt, 0.7);
						transitioning = true;
						new FlxTimer().start(2, function(tmr)
						{
                            
							FlxG.sound.music.stop();
							MusicBeatState.switchState(new MainMenuState());
						});
					}

		super.update(elapsed);
	
	}
		

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(!closedState) {
			sickBeats++;
		}
	}

	var increaseVolume:Bool = false;

	var logoBumpin:FlxSprite;
	var chains:FlxSprite;
	var intro1:FlxSprite;
	var intro2:FlxSprite;
	var intro3:FlxSprite;
	var intro4:FlxSprite;
	var intro5:FlxSprite;
	var titleBG:FlxSprite;
		function skipIntro():Void
			{
			if (!skippedIntro)
			{
				skippedIntro = true;
				makeTitle();
				if (black != null)
					black.destroy();
			}
			}


	function startRealIntro()
		{
			if (introPhase == 1)
			{
				remove(intro1);
				intro1.destroy();
		
				intro2 = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/warningImage2.png');
				intro2.screenCenter();
				intro2.scale.set(0.48, 0.48);
				intro2.scrollFactor.set();
				add(intro2);
				
				intro2.x -= 600;
				FlxTween.tween(intro2, {x: intro2.x + 600}, 0.6, {ease: FlxEase.elasticOut});
			}
		
			if (introPhase == 2)
			{
				remove(intro2);
				intro2.destroy();
		
				intro3 = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/warningImage3.png');
				intro3.screenCenter();
				intro3.scale.set(0.48, 0.48);
				intro3.scrollFactor.set();
				add(intro3);
				
				intro3.x += 600;
				FlxTween.tween(intro3, {x: intro3.x - 600}, 0.6, {ease: FlxEase.elasticOut});
			}

			if (introPhase == 3)
			{
				remove(intro3);
				intro3.destroy();
		
				intro4 = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/warningImage4.png');
				intro4.screenCenter();
				intro4.scale.set(0.48, 0.48);
				intro4.scrollFactor.set();
				add(intro4);
				
				intro4.x -= 600;
				FlxTween.tween(intro4, {x: intro4.x + 600}, 0.6, {ease: FlxEase.elasticOut});
			}

			if (introPhase == 4)
			{
				remove(intro4);
				intro4.destroy();
				remove(chains);
				chains.destroy();
		
				intro5 = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/warningImage5.png');
				intro5.screenCenter();
				intro5.scale.set(0.48, 0.48);
				intro5.scrollFactor.set();
				add(intro5);
			}
		}

		function makeTitle()
			{
				remove(intro5);
				intro5.destroy();
				remove(pressText);
				
				FlxG.camera.flash(0xFF000000, 2, null, true);
		

						FlxG.sound.playMusic('assets/music/Title_Menu.ogg', 1);
				
				titleBG = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/bgback.png');
				titleBG.scale.set(0.68, 0.68);
				titleBG.scrollFactor.set();
				titleBG.screenCenter();
				add(titleBG);
			
				var creepy:FlxSprite = new FlxSprite(0, 0).loadGraphic('assets/images/loadingFunkers.png');
				creepy.scrollFactor.set();
				creepy.antialiasing = true;
				creepy.scale.set(0.25, 0.25);
				creepy.screenCenter();
				creepy.x -= 300;
			add(creepy);

				logoBumpin = new FlxSprite(0, 0).loadGraphic('assets/images/logoBumpinONLY.png');
				logoBumpin.scale.set(0.68, 0.68);
				logoBumpin.scrollFactor.set();
				logoBumpin.screenCenter();
				logoBumpin.antialiasing = true;
				logoBumpin.x += 320;
				logoBumpin.y -= 20;
				add(logoBumpin);
		
				add(pressText);
				pressText.active = true;
				pressText.alpha = 1;
				pressText.scale.set(0.35, 0.35);
				pressText.screenCenter();
				pressText.x += 400;
				pressText.y += 150;
			}

}