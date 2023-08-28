package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;


using StringTools;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '5.0.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var bgMenu:FlxSprite;
	var bgGrid:FlxSprite;
	var menuItemsDark:FlxGroup;
	var menuItemsLight:FlxGroup;
	var darkbars:FlxGroup;
	var lightbars:FlxGroup;
	var charMenu:FlxSprite;
	var charEye:FlxSprite;
	var fire:FlxSprite;

	override function create()
	{
		if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('It\'s her fault'), 0);
			}
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;


		var bg = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);


		fire = new FlxSprite();
		fire.frames = FlxAtlasFrames.fromSparrow('assets/images/corruptionStuff/fireblow.png', 'assets/images/corruptionStuff/fireblow.xml');
		fire.animation.addByPrefix('fire', "fireEffect", 18);
		fire.antialiasing = ClientPrefs.globalAntialiasing;
		fire.animation.play('fire');
	//	fire.blend = 0;
		fire.scale.set(2.2, 2.2);
		fire.x = -100;
		fire.y = 0;
		fire.updateHitbox();
		add(fire);



		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		var random = FlxG.random.int(0,2);

		var charGrap:String;
		var charEyGr:String;

		if (random == 0)
		{
			charGrap = 'assets/images/corruptionStuff/menuBF.png';
			charEyGr = 'assets/images/corruptionStuff/menuBFeye.png';
		}
		else if (random == 1)
		{
			charGrap = 'assets/images/corruptionStuff/menuNEU.png';
			charEyGr = 'assets/images/corruptionStuff/menuNEUeye.png';
		}
		else
		{
			charGrap = 'assets/images/corruptionStuff/GFEYES.png';
			charEyGr = 'assets/images/corruptionStuff/GFNOEYES.png';
		}

		charMenu = new FlxSprite(0, 0).loadGraphic(charGrap);
		charMenu.scrollFactor.set();
		charMenu.antialiasing = ClientPrefs.globalAntialiasing;
		add(charMenu);
	
		charEye = new FlxSprite(0, 0).loadGraphic(charEyGr);
    charEye.scrollFactor.set();
    charEye.antialiasing = ClientPrefs.globalAntialiasing;
    charEye.visible = false;
    add(charEye);

	charMenu.x -= charMenu.width;
    charEye.x -= charEye.width;
		new FlxTimer().start(0.5, function(tmr)
			{
				FlxTween.tween(charMenu, {x: charMenu.x + charMenu.width}, 1.5, {ease: FlxEase.cubeOut});
				FlxTween.tween(charEye, {x: charEye.x + charEye.width}, 1.5, {ease: FlxEase.cubeOut});
			});
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		darkbars = new FlxGroup();
		add(darkbars);

		for (i in 0...4)
			{
				var menuItem = new FlxSprite(790, 140 + (i * 110)).loadGraphic('assets/images/corruptionStuff/notselect.png');
				menuItem.ID = i;
				darkbars.add(menuItem);
				menuItem.antialiasing = true;
				menuItem.active = false;
			}
			lightbars = new FlxGroup();
		add(lightbars);
			for (i in 0...4)
			{
				var menuItem = new FlxSprite(660, 145 + (i * 110)).loadGraphic('assets/images/corruptionStuff/selected.png');
				menuItem.ID = i;
				lightbars.add(menuItem);
				menuItem.antialiasing = true;
				menuItem.active = false;
				menuItem.visible = false;
			}


	menuItemsDark = new FlxGroup();
	add(menuItemsDark);
    
	for (i in 0...4)
		{
			var menuItem = new FlxSprite(720, 145 + (i * 110)).loadGraphic('assets/images/corruptionStuff/mainmenu' + i + '.png');
			menuItem.ID = i;
			menuItemsDark.add(menuItem);
			menuItem.antialiasing = true;
			menuItem.active = false;
		}
		menuItemsLight = new FlxGroup();
		add(menuItemsLight);
		 for (i in 0...4)
		{
			var menuItem = new FlxSprite(720, 145 + (i * 110)).loadGraphic('assets/images/corruptionStuff/mainselected' + i + '.png');
			menuItem.ID = i;
			menuItemsLight.add(menuItem);
			menuItem.antialiasing = true;
			menuItem.active = false;
			menuItem.visible = false;
		}
	

		bgGrid = new FlxSprite(0, 0).loadGraphic('assets/images/corruptionStuff/seperators.png');
		bgGrid.screenCenter();
		bgGrid.scrollFactor.set();
		add(bgGrid);


		//FlxG.camera.follow(camFollowPos, null, 1);




		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Neu's Scarletion v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
				if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
			}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
				charEye.visible = true;
				FlxG.camera.flash(0xFFffffff, 1, null, true);



				new FlxTimer().start(1.1, function(tmr)
				{
					switch (optionShit[curSelected])
					{
						case 'story_mode':
							new FlxTimer().start(1.1, function(tmr)
								{
									if(FreeplayState.vocals != null) FreeplayState.vocals.fadeOut(1.2);
									FlxG.sound.music.fadeOut(1.2);
			
									new FlxTimer().start(1.2, function(tmr)
									{
											FlxG.sound.music.stop();
											if(FreeplayState.vocals != null) FreeplayState.vocals.stop();
											MusicBeatState.switchState(new StoryMenuState());
									});
								});

						case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());

						case 'credits':
							MusicBeatState.switchState(new CreditsState());
						case 'options':
							LoadingState.loadAndSwitchState(new options.OptionsState());
					}
				});
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			else if (FlxG.keys.justPressed.ONE)
				{
					selectedSomethin = true;
					MusicBeatState.switchState(new AchievementsMenuState());
				}
				else if (FlxG.keys.justPressed.TWO)
					{
						selectedSomethin = true;
						MusicBeatState.switchState(new ModsMenuState());
					}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected > 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 3;

		menuItemsDark.forEach(function(spr)
			{
				spr.visible = true;
				
				if (spr.ID == curSelected)
				{
					spr.visible = false;
				}
			});
	
			menuItemsLight.forEach(function(spr)
			{
				spr.visible = false;
				
				if (spr.ID == curSelected)
				{
					spr.visible = true;
				}
			});
	
			darkbars.forEach(function(spr)
			{
				spr.visible = true;
				
				if (spr.ID == curSelected)
				{
					spr.visible = false;
				}
			});
	
			lightbars.forEach(function(spr)
			{
				spr.visible = false;
				
				if (spr.ID == curSelected)
				{
					spr.visible = true;
				}
			});
		}
}
