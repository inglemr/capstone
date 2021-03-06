	$.root_ = $('body');	
	$.navAsAjax = false; 
/*
 * GLOBAL: Sound Config (define sound path, enable or disable all sounds)
 */
	$.sound_path = "sound/";
	$.sound_on = true; 
/*
 * SAVE INSTANCE REFERENCE (DO NOT CHANGE)
 * Save a reference to the global object (window in the browser)
 */
	var root = this,	
	throttle_delay = 350,
/*
 * The rate at which the menu expands revealing child elements on click
 */
	menu_speed = 235,	
/*
 * Collapse current menu item as other menu items are expanded
 * Careful when using this option, if you have a long menu it will
 * keep expanding and may distrupt the user experience This is best 
 * used with fixed-menu class
 */
	menu_accordion = true,	
/*
 * Turn on JarvisWidget functionality
 * Global JarvisWidget Settings
 * For a greater control of the widgets, please check app.js file
 * found within COMMON_ASSETS/UNMINIFIED_JS folder and see from line 1355
 * dependency: js/jarviswidget/jarvis.widget.min.js
 */
	enableJarvisWidgets = true,
/*
 * Use localstorage to save widget settings
 * turn this off if you prefer to use the onSave hook to save
 * these settings to your datatabse instead
 */	
	localStorageJarvisWidgets = true,
/*
 * Turn off sortable feature for JarvisWidgets 
 */	
	sortableJarvisWidgets = true,		
/*
 * Warning: Enabling mobile widgets could potentially crash your webApp 
 * if you have too many widgets running at once 
 * (must have enableJarvisWidgets = true)
 */
	enableMobileWidgets = false,	
/*
 * Turn on fast click for mobile devices
 * Enable this to activate fastclick plugin
 * dependency: js/plugin/fastclick/fastclick.js 
 */
	fastClick = false,
/*
 * SMARTCHAT PLUGIN ARRAYS & CONFIG
 * Dependency: js/plugin/moment/moment.min.js 
 *             js/plugin/cssemotions/jquery.cssemoticons.min.js 
 *             js/smart-chat-ui/smart.chat.ui.js
 * (DO NOT CHANGE BELOW) 
 */	
	boxList = [],
	showList = [],
 	nameList = [],
	idList = [],
/*
 * Width of the chat boxes, and the gap inbetween in pixel (minus padding)
 */	
	chatbox_config = {
	    width: 200,
	    gap: 35
	},
/*
 * These elements are ignored during DOM object deletion for ajax version 
 * It will delete all objects during page load with these exceptions:
 */
	ignore_key_elms = ["#header, #left-panel, #right-panel, #main, div.page-footer, #shortcut, #divSmallBoxes, #divMiniIcons, #divbigBoxes, #voiceModal, script, .ui-chatbox"],
/*
 * VOICE COMMAND CONFIG
 * dependency: js/speech/voicecommand.js
 */
	voice_command = true,
/*
 * Turns on speech as soon as the page is loaded
 */	
	voice_command_auto = false,
	voice_command_lang = 'en-US',
/*
 * 	Use localstorage to remember on/off (best used with HTML Version
 * 	when going from one page to the next)
 */	
	voice_localStorage = true;
/*
 * Voice Commands
 * Defines voice command variables and functions
 */	
 	if (voice_command) {
	 		
		var commands = {
					
			'show dashboard' : function() { $('nav a[href="dashboard.php"]').trigger("click"); },
			'show inbox' : function() { $('nav a[href="inbox.php"]').trigger("click"); },
			'show graphs' : function() { $('nav a[href="flot.php"]').trigger("click"); },
			'show flotchart' : function() { $('nav a[href="flot.php"]').trigger("click"); },
			'show morris chart' : function() { $('nav a[href="morris.php"]').trigger("click"); },
			'show inline chart' : function() { $('nav a[href="inline-charts.php"]').trigger("click"); },
			'show dygraphs' : function() { $('nav a[href="dygraphs.php"]').trigger("click"); },
			'show tables' : function() { $('nav a[href="table.php"]').trigger("click"); },
			'show data table' : function() { $('nav a[href="datatables.php"]').trigger("click"); },
			'show jquery grid' : function() { $('nav a[href="jqgrid.php"]').trigger("click"); },
			'show form' : function() { $('nav a[href="form-elements.php"]').trigger("click"); },
			'show form layouts' : function() { $('nav a[href="form-templates.php"]').trigger("click"); },
			'show form validation' : function() { $('nav a[href="validation.php"]').trigger("click"); },
			'show form elements' : function() { $('nav a[href="bootstrap-forms.php"]').trigger("click"); },
			'show form plugins' : function() { $('nav a[href="plugins.php"]').trigger("click"); },
			'show form wizards' : function() { $('nav a[href="wizards.php"]').trigger("click"); },
			'show bootstrap editor' : function() { $('nav a[href="other-editors.php"]').trigger("click"); },
			'show dropzone' : function() { $('nav a[href="dropzone.php"]').trigger("click"); },
			'show image cropping' : function() { $('nav a[href="image-editor.php"]').trigger("click"); },
			'show general elements' : function() { $('nav a[href="general-elements.php"]').trigger("click"); },
			'show buttons' : function() { $('nav a[href="buttons.php"]').trigger("click"); },
			'show fontawesome' : function() { $('nav a[href="fa.php"]').trigger("click"); },
			'show glyph icons' : function() { $('nav a[href="glyph.php"]').trigger("click"); },
			'show flags' : function() { $('nav a[href="flags.php"]').trigger("click"); },
			'show grid' : function() { $('nav a[href="grid.php"]').trigger("click"); },
			'show tree view' : function() { $('nav a[href="treeview.php"]').trigger("click"); },
			'show nestable lists' : function() { $('nav a[href="nestable-list.php"]').trigger("click"); },
			'show jquery U I' : function() { $('nav a[href="jqui.php"]').trigger("click"); },
			'show typography' : function() { $('nav a[href="typography.php"]').trigger("click"); },
			'show calendar' : function() { $('nav a[href="calendar.php"]').trigger("click"); },
			'show widgets' : function() { $('nav a[href="widgets.php"]').trigger("click"); },
			'show gallery' : function() { $('nav a[href="gallery.php"]').trigger("click"); },
			'show maps' : function() { $('nav a[href="gmap-xml.php"]').trigger("click"); },
			'show pricing tables' : function() { $('nav a[href="pricing-table.php"]').trigger("click"); },
			'show invoice' : function() { $('nav a[href="invoice.php"]').trigger("click"); },
			'show search' : function() { $('nav a[href="search.php"]').trigger("click"); },
			'go back' :  function() { history.back(1); }, 
			'scroll up' : function () { $('html, body').animate({ scrollTop: 0 }, 100); },
			'scroll down' : function () { $('html, body').animate({ scrollTop: $(document).height() }, 100);},
			'hide navigation' : function() { 
				if ($.root_.hasClass("container") && !$.root_.hasClass("menu-on-top")){
					$('span.minifyme').trigger("click");
				} else {
					$('#hide-menu > span > a').trigger("click"); 
				}
			},
			'show navigation' : function() { 
				if ($.root_.hasClass("container") && !$.root_.hasClass("menu-on-top")){
					$('span.minifyme').trigger("click");
				} else {
					$('#hide-menu > span > a').trigger("click"); 
				}
			},
			'mute' : function() {
				$.sound_on = false;
				$.smallBox({
					title : "MUTE",
					content : "All sounds have been muted!",
					color : "#a90329",
					timeout: 4000,
					icon : "fa fa-volume-off"
				});
			},
			'sound on' : function() {
				$.sound_on = true;
				$.speechApp.playConfirmation();
				$.smallBox({
					title : "UNMUTE",
					content : "All sounds have been turned on!",
					color : "#40ac2b",
					sound_file: 'voice_alert',
					timeout: 5000,
					icon : "fa fa-volume-up"
				});
			},
			'stop' : function() {
				smartSpeechRecognition.abort();
				$.root_.removeClass("voice-command-active");
				$.smallBox({
					title : "VOICE COMMAND OFF",
					content : "Your voice commands has been successfully turned off. Click on the <i class='fa fa-microphone fa-lg fa-fw'></i> icon to turn it back on.",
					color : "#40ac2b",
					sound_file: 'voice_off',
					timeout: 8000,
					icon : "fa fa-microphone-slash"
				});
				if ($('#speech-btn .popover').is(':visible')) {
					$('#speech-btn .popover').fadeOut(250);
				}
			},
			'help' : function() {
				$('#voiceModal').removeData('modal').modal( { remote: "ajax/modal-content/modal-voicecommand.html", show: true } );
				if ($('#speech-btn .popover').is(':visible')) {
					$('#speech-btn .popover').fadeOut(250);
				}
			},		
			'got it' : function() {
				$('#voiceModal').modal('hide');
			},	
			'logout' : function() {
				$.speechApp.stop();
				window.location = $('#logout > span > a').attr("href");
			}
		}; 
		
	};
/*
 * END APP.CONFIG
 */ 
 
 
 
 
 	