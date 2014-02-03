/*
 *
 *	CoolText
 *
 *	Copyright (c) 2014 Thomas Dolso
 *	http://www.cooltextjs.com
 *
 *	Licensed under http://codecanyon.net/licenses/regular
 *
 */

;(function ($, window, document, undefined) {

	"use strict";

	var pluginName = "cooltext";
	var options;
	
	var defaults = {
		cycle:false,
		pauseOnMouseOver:false,
		resumeOnMouseOut:false,
		waitForLoad:false,
		animations:[],
		onComplete:undefined,
		onMouseOver:undefined,
		onMouseOut:undefined,
		onClick:undefined
	};

	
	function Plugin(element, options) {

		this.name = pluginName;
		this.defaults = defaults;
		this.options = $.extend({}, defaults, options);

		if (this.options.sequence === undefined)
			this.options.sequence = [];
		this.num_actions = this.options.sequence.length;
		this.current_action = 0;

		this.element = element;
		this.j_element = $(element);

		this.timeline = new TimelineMax();

		this.num_letters = 0;
		this.num_words = 0;

		$.extend(this.options.animations, cool_animations);

		if (this.options.waitForLoad)
		{
			var plugin = this;
			$(window).load(function(){
				plugin._init();
		   });
		}
		else
			this._init();
	}



	var onMouseOver = function(event)
	{
		var plugin = event.data.plugin;

		if ((typeof plugin.options.onMouseOver.overwrite === 'undefined' || !plugin.options.onMouseOver.overwrite) &&
			 (plugin.animating || plugin.animating_over || plugin.animating_out || plugin.animating_click))
			return false;
		plugin.animating_over = true;
		
		var animation = $.extend(true, {}, plugin.options.onMouseOver);
		if ($.isArray(animation.animation))
			plugin._getRandomAnimation(animation);
		else
			plugin._getAnimation(animation);
		plugin._getAnimationInfo(animation);

		plugin.pause();
		plugin._startAnimation(animation, true);
	}
	

	var onMouseOut = function(event)
	{
		var plugin = event.data.plugin;

		if ((typeof plugin.options.onMouseOut.overwrite === 'undefined' || !plugin.options.onMouseOut.overwrite) &&
			 (plugin.animating || plugin.animating_over || plugin.animating_out || plugin.animating_click))
			return false;
		plugin.animating_out = true;

		var animation = $.extend(true, {}, plugin.options.onMouseOut);
		if ($.isArray(animation.animation))
			plugin._getRandomAnimation(animation);
		else
			plugin._getAnimation(animation);
		plugin._getAnimationInfo(animation);

		plugin.pause();
		plugin._startAnimation(animation, true);
	}


	var onClick = function(event)
	{
		var plugin = event.data.plugin;

		if ((typeof plugin.options.onClick.overwrite === 'undefined' || !plugin.options.onClick.overwrite) &&
			 (plugin.animating || plugin.animating_over || plugin.animating_out || plugin.animating_click))
			return false;
		plugin.animating_click = true;

		var animation = $.extend(true, {}, plugin.options.onClick);
		if ($.isArray(animation.animation))
			plugin._getRandomAnimation(animation);
		else
			plugin._getAnimation(animation);
		plugin._getAnimationInfo(animation);

		plugin.pause();
		plugin._startAnimation(animation, true);
	}
	
	


	Plugin.prototype = {
		

		// PRIVATE METHODS ///////////////////////////////////////////////////////////////////////////////////////////////////////////

		_init: function() {
			
			var plugin = this;

			if (plugin.options.pauseOnMouseOver)
				plugin.j_element.on('mouseenter', { plugin: this }, function(){plugin.pause();});
			if (plugin.options.resumeOnMouseOut)
				plugin.j_element.on('mouseleave', { plugin: this }, function(){plugin.play();});
			
			if (plugin.options.onMouseOver)
				plugin.j_element.on('mouseenter', { plugin: this }, onMouseOver);
			if (plugin.options.onMouseOut)
				plugin.j_element.on('mouseleave', { plugin: this }, onMouseOut);
			if (plugin.options.onClick)
				plugin.j_element.on('click', { plugin: this }, onClick);

			plugin._getAnimations();
			plugin._createLetters();
			plugin._doAction();
		},


		_getAnimation: function(s)
		{
			if (typeof s === 'undefined')
				return;

			var plugin = this;
			
			if ($.isArray(s.animation))
				s.action = "do_animate";

			else if (s.action == "animation" && s.animation != "")
			{
				var found = false;
				for (var j=0; j<plugin.options.animations.length; j++)
				{
					if (s.animation == plugin.options.animations[j].name)
					{
						found = true;
						s.action = "do_animate";
						s.steps = jQuery.extend(true, [], plugin.options.animations[j].steps);
					}
				}

				if (!found)
				{
					console.log("COOLTEXT WARNING: animation " + s.animation + " not found");
					plugin.options.sequence.splice(j,1);
					plugin.num_actions--;
				}
			}
		},

		
		_getAnimations: function()
		{
			var plugin = this;

			for (var i=0; i<plugin.options.sequence.length; i++)
			{
				var s = plugin.options.sequence[i];
				plugin._getAnimation(s);
			}
		},


		_getRandomAnimation: function(s)
		{
			var plugin = this;

			if ($.isArray(s.animation))
			{
				var a = Math.floor(s.animation.length * Math.random());
				s.name = s.animation[a];

				var found = false;
				for (var j=0; j<plugin.options.animations.length; j++)
				{
					if (s.name == plugin.options.animations[j].name)
					{
						found = true;
						s.steps = jQuery.extend(true, [], plugin.options.animations[j].steps);
					}
				}

				if (!found)
				{
					console.log("COOLTEXT WARNING: animation " + s.name + " not found");
					plugin.options.sequence.splice(j,1);
					plugin.num_actions--;
				}
			}
		},


		_createLetters: function()
		{
			var plugin = this;
			
			plugin.j_element.html(plugin.j_element.html().replace(/\n/g, '').replace("\t", "").replace(/\s{2,}/g, ' '));
			plugin.current_text = plugin.j_element.html();
			plugin.j_element.html($.trim(plugin.j_element.html()));
			
			var el = plugin.j_element.clone();
			plugin.j_element.html("");
			el.find("br").replaceWith("\n");

			var letters = el.text().split("");
			var letter;

			var word = $("<div/>", {css:{position:"relative", display:"inline-block"}}).addClass('ct-word').appendTo(plugin.j_element);
			$.each(letters, function(index, val)
			{
				if (val === "\n")
				{
					$("<br/>", {css:{position:"relative", display:"inline-block"}}).addClass('ct-br').appendTo(plugin.j_element);
					word = $("<div/>", {css:{position:"relative", display:"inline-block"}}).addClass('ct-word').appendTo(plugin.j_element);
				}

				if (val == " " || val == "&nbsp;")
				{
					plugin.j_element.append(" ");
					word = $("<div/>", {css:{position:"relative", display:"inline-block"}}).addClass('ct-word').appendTo(plugin.j_element);
				}
				else
				{
					letter = $("<div/>", {css:{
						position:"relative",
						display:"inline-block"
						//"-webkit-font-smoothing": "antialiased",
						//"-moz-font-smoothing":"antialiased"
					}}).addClass('ct-letter').html(val).appendTo(word);
				}
			});

						
			plugin._finds();

			plugin.words_positions = Array();
			$.each(plugin.words, function(index, val) {
				var p = $(this).position();
				plugin.words_positions[index] = p;
			});

			plugin.letters_positions = Array();
			$.each(plugin.letters, function(index, val) {
				var p = $(this).position();
				plugin.letters_positions[index] = p;
			});
			

			TweenMax.set(plugin.j_element, {z:0.1});

			if (typeof plugin.options.sequence === undefined || plugin.options.sequence.length == 0)
				plugin.j_element.css("visibility", "visible");

			plugin._createResetValues();
		},


		_finds: function()
		{
			var plugin = this;

			plugin.letters = plugin.j_element.find(".ct-letter");
			plugin.words = plugin.j_element.find(".ct-word");
			plugin.num_letters = plugin.letters.length;
			plugin.num_words = plugin.words.length;
		},


		_resetLetters: function()
		{
			var plugin = this;
			$.each(plugin.letters, function(idx, val) {
				TweenMax.to(this, 0, plugin.letters_reset[idx]);
			});
		},


		_resetWords: function()
		{
			var plugin = this;
			$.each(plugin.words, function(idx, val) {
				TweenMax.to(this, 0, plugin.words_reset[idx])
			});
		},


		_createResetValues: function()
		{
			var plugin = this;

			plugin.words_reset = Array();
			$.each(plugin.words, function(idx, val) {
				plugin.words_reset[idx] = {
					transformOrigin:"50% 50% 0",
					transform:"none",
					rotationY:0,
					rotationX:0,
					rotation:0,
					scale:1,
					opacity:1,
					immediateRender:true
				};
			});

			plugin.letters_reset = Array();
			$.each(plugin.letters, function(idx, val) {
				plugin.letters_reset[idx] = {
					transformOrigin:"50% 50% 0",
					transform:"none",
					rotationY:0,
					rotationX:0,
					rotation:0,
					scale:1,
					opacity:1,
					immediateRender:true
				};
			});
		},



		_nextAction: function()
		{
			var plugin = this;
			plugin.current_action++;
			if (plugin.current_action >= plugin.num_actions)
			{
				if (plugin.options.onComplete !== undefined)
					plugin.options.onComplete();
				if (plugin.options.cycle)
					plugin.current_action = 0;
				else
					return false;
			}

			plugin._doAction();
			return true;
		},


		_prevAction: function()
		{
			var plugin = this;
			plugin.current_action--;
			if (plugin.current_action < 0) {
				return false;
			}

			plugin._doAction();
			return true;
		},



		_getAnimationInfo: function(animation)
		{
			var plugin = this;

			plugin.current_animation = {};

			if (animation.elements == "words")
			{
				plugin.current_animation.num_elements = plugin.num_words;
				plugin.current_animation.jelements = ".ct-word";
				plugin.current_animation.stagger_multiplier = 7;
			}
			else
			{
				plugin.current_animation.num_elements = plugin.num_letters;
				plugin.current_animation.jelements = ".ct-letter";
				plugin.current_animation.stagger_multiplier = 1;
			}


			for(var i=1; i<animation.steps.length; i++)
			{
				var s = animation.steps[i];
				
				if (animation.speed != undefined)
					s.time *= 100 / animation.speed;

				if (animation.stagger != undefined)
					s.stagger *= 100 / animation.stagger;
				
				s.stagger *= plugin.current_animation.stagger_multiplier;
			}


			for (var i=1; i<animation.steps.length; i++)
			{
				var step = animation.steps[i];
				step.total_time = (plugin.current_animation.num_elements - 1) * parseFloat(step.stagger) + parseFloat(step.time); 
			}

			var delay = 0;
			animation.steps[1].delay = 0;
			for (var i=2; i<animation.steps.length; i++)
			{
				delay += animation.steps[i-1].total_time * animation.steps[i].start_at;
				animation.steps[i].delay = delay;
			}

			plugin.current_animation.total_time = 0;
			for (var i=1; i<animation.steps.length; i++)
				if (animation.steps[i].total_time + animation.steps[i].delay > plugin.current_animation.total_time)
					plugin.current_animation.total_time = animation.steps[i].total_time + animation.steps[i].delay;

			plugin.current_animation.one_element_total_time = 0;
			for (var i=1; i<animation.steps.length; i++)
				if (animation.steps[i].time + animation.steps[i].delay > plugin.current_animation.one_element_total_time)
					plugin.current_animation.one_element_total_time = animation.steps[i].time + animation.steps[i].delay;
		},



		_doAction: function()
		{
			var plugin = this;

			if (plugin.options.sequence.length == 0)
				return false;

			var s = $.extend(true, {}, plugin.options.sequence[plugin.current_action]);

			switch(s.action)
			{
				case "do_animate":

					if ($.isArray(s.animation))
						plugin._getRandomAnimation(s);

					plugin._getAnimationInfo(s);
					plugin._startAnimation(s);
					break;

				case "update":

					plugin.j_element.css("visibility", "hidden");
					if (s.text !== undefined)
						plugin.j_element.html(s.text);
					else
						plugin.j_element.html(plugin.current_text);

					if (s.addClass !== undefined)
						plugin.j_element.addClass(s.addClass);
					if (s.removeClass !== undefined)
						plugin.j_element.removeClass(s.removeClass);

					if (typeof s.css !== undefined)
						TweenMax.set(plugin.j_element, {css:s.css});

					plugin._createLetters();
					plugin._nextAction();
					break;
			}
		},



		_resetElements: function()
		{
			var plugin = this;

			if (plugin.current_animation.jelements == ".ct-letter")
				plugin._resetWords();
			else if (plugin.current_animation.jelements == ".ct-word")
				plugin._resetLetters();
		},


		
		_startAnimation: function(animation, nofollow)
		{
			var plugin = this;

			plugin.animating = true;

			if (nofollow === undefined)
				nofollow = false;

			var s = animation.steps[0];

			if (animation.onStart !== undefined)
			{
				if (animation.delay !== undefined)
					TweenMax.delayedCall(animation.delay, function(){animation.onStart()});
				else
					animation.onStart();
			}

			TweenLite.set(plugin.words, {perspective: s.p});
			
			plugin.timeline.clear();
			plugin.timeline = new TimelineMax();
			plugin.timeline.pause();
			plugin.timeline.eventCallback("onComplete", function(){
				plugin._resetElements(); 
				plugin._doSteps(animation, nofollow); 
			});

			if ($(plugin.j_element).css("visibility") != "visible")
				TweenMax.to(plugin.j_element, 0, {delay:(animation.delay === undefined) ? 0 : animation.delay, visibility:"visible"});
			
			var tweens = Array();
			$.each(plugin.j_element.find(plugin.current_animation.jelements), function(idx, val) {

				if (s.xt == "value")
					var value_x = s.x;
				else if (s.xt == "random")
					var value_x = Math.floor(s.x1 + (s.x2 - s.x1) * Math.random());
				if (s.yt == "value")
					var value_y = s.y;
				else if (s.yt == "random")
					var value_y = Math.floor(s.y1 + (s.y2 - s.y1) * Math.random());

				var opacity = s.o;
				if (animation.startingOpacity !== undefined)
					opacity = animation.startingOpacity;

				tweens.push(
					TweenMax.to(
						this,
						0,
						{
							opacity: opacity,
							transformOrigin: s.tox + "% " + s.toy + "% " + s.toz + "px",
							x: value_x,
							y: value_y,
							z: 0.1,
							rotationX: s.rx,
							rotationY: s.ry,
							rotationZ: s.rz,
							scaleX: s.sx,
							scaleY: s.sy,
							delay:(animation.delay === undefined) ? 0 : animation.delay
						}
					)
				);
			});

			plugin.timeline.add(tweens);
			plugin.timeline.play();
		},
		


		_doSteps: function(animation, nofollow)
		{
			var plugin = this;

			plugin.timeline.clear();
			plugin.timeline = new TimelineMax();
			plugin.timeline.pause();

			plugin.timeline.eventCallback("onComplete", function(){

				plugin.animating = false;
				plugin.animating_over = false;
				plugin.animating_out = false;
				plugin.animating_click = false;

				if (animation.onComplete !== undefined)
					animation.onComplete();

				if (!nofollow && !animation.stop)
					plugin._nextAction();
			});



			var elems = plugin.j_element.find(plugin.current_animation.jelements);

			var indexes = Array();
			if (animation.order == "reverse") {
				for(var e=0; e<plugin.current_animation.num_elements; e++)
					indexes[e] = plugin.current_animation.num_elements - e - 1;
			}
			else if (animation.order == "random") {
				for(var e=0; e<plugin.current_animation.num_elements; e++)
					indexes[e] = e;
				for(var e=0; e<plugin.current_animation.num_elements; e++)
				{
					var x = Math.floor(Math.random() * plugin.current_animation.num_elements);
					var tmp = indexes[e];
					indexes[e] = indexes[x];
					indexes[x] = tmp;
				}
			}
			else {
				for(var e=0; e<plugin.current_animation.num_elements; e++)
					indexes[e] = e;
			}


			for(var i=1; i<animation.steps.length; i++)
			{
				var s = animation.steps[i];
				var s_prev = animation.steps[i-1];

				TweenLite.set(plugin.words, {perspective: s.p});
			
				var values = {};
				if (s.o != s_prev.o)
					values.opacity = s.o;
				if (s.tox != s_prev.tox || s.toy != s_prev.toy || s.toz != s_prev.toz)
					values.transformOrigin = s.tox + "% " + s.toy + "% " + s.toz + "px";
				if (s.rx != s_prev.rx)
					values.rotationX = s.rx;
				if (s.ry != s_prev.ry)
					values.rotationY = s.ry;
				if (s.rz != s_prev.rz)
					values.rotationZ = s.rz;
				if (s.sx != s_prev.sx)
					values.scaleX = s.sx;
				if (s.sy != s_prev.sy)
					values.scaleY = s.sy;

				values.z = 0.1;
				values.ease = s.e;

				for(var e=0; e<plugin.current_animation.num_elements; e++)
				{
					if (s.xt == "random")
						var x = Math.floor(s.x1 + (s.x2 - s.x1) * Math.random());
					else if (s.xt != s_prev.type || s.x != s_prev.x)
						var x = s.x;
					if (s.yt == "random")
						var y = Math.floor(s.y1 + (s.y2 - s.y1) * Math.random());
					else if (s.yt != s_prev.type || s.y != s_prev.y)
						var y = s.y;

					plugin.timeline.add(
						TweenMax.to(
							elems[indexes[e]],
							s.time,
							$.extend({}, values, {
								x:x,
								y:y
							})
						),
						s.delay + e*s.stagger
					);
					
					if (typeof animation.css !== undefined)
					{
						plugin.timeline.add(
							TweenMax.to(
								elems[indexes[e]],
								plugin.current_animation.one_element_total_time,
								{css:animation.css}
							),
							0 + e*s.stagger
						);
					}
				}
			}

			plugin.timeline.play();
		},


		_doBefore: function(params)
    	{
    		var plugin = this;
    		var animation = $.extend(true, {}, params.before);

    		animation.onComplete = function(){
    			params.before = undefined;
    			plugin.goto(params);
    		};
			plugin._getAnimation(animation);
			plugin._getAnimationInfo(animation);
			plugin._startAnimation(animation, true);
    	},




		// PUBLIC METHODS ///////////////////////////////////////////////////////////////////////////////////////////////////////////

		restart: function(params) {
      	var plugin = this;
      	plugin.current_action = 0;
			plugin._doAction();
    	},


    	pause: function(params) {
      	var plugin = this;
      	plugin.timeline.pause();
    	},


    	play: function(params) {
      	var plugin = this;
      	plugin.timeline.play();
    	},


    	goto: function(params)
    	{
    		var plugin = this;
    		var starting = plugin.current_action;

    		if (params.before !== undefined)
    		{
    			plugin._doBefore(params);
    			return;
    		}

    		switch(params.where)
    		{
    			case "next":
    				if (plugin.current_action >= plugin.num_actions-1)
		      	{
		      		if (plugin.options.cycle)
		      		{
		      			plugin.current_action = -1;
		      			plugin._nextAction();
		      		}
		      	}
		      	else
		      		plugin._nextAction();
    				break;

    			case "prev":
    				if (plugin.current_action <= 0)
		      	{
		      		if (plugin.options.cycle)
		      		{
		      			plugin.current_action = plugin.num_actions;
		      			plugin._prevAction();
		      		}
		      	}
		      	else
		      		plugin._prevAction();
    				break;

    			case "next_update":
					do {
						plugin.current_action++;
						if (plugin.current_action >= plugin.num_actions)
							plugin.current_action = 0;
						if (plugin.options.sequence[plugin.current_action].action == "update")
						{
							if (params.stagger !== undefined)
							{
								plugin.current_action += parseInt(params.stagger);
								if (plugin.current_action >= plugin.num_actions)
									plugin.current_action = 0;
								else if (plugin.current_action < 0)
									plugin.current_action = plugin.num_actions - 1;
							}
							plugin._doAction();
							return plugin.current_action;
						}
					} while(plugin.current_action != starting)
					return false;
    				break;

    			case "prev_update":
    				var found = false;
					do {
						plugin.current_action--;
						if (plugin.current_action < 0)
							plugin.current_action = plugin.num_actions - 1;
						if (plugin.options.sequence[plugin.current_action].action == "update")
						{
							if (found)
							{
								if (params.stagger !== undefined)
								{
									plugin.current_action += parseInt(params.stagger);
									if (plugin.current_action >= plugin.num_actions)
										plugin.current_action = 0;
									else if (plugin.current_action < 0)
										plugin.current_action = plugin.num_actions - 1;
								}

								plugin._doAction();
								return plugin.current_action;
							}
							else
								found = true;
						}
					} while(plugin.current_action != starting)
					return false;
    				break;
    		}
    	}


	};


	$.fn[pluginName] = function(options)
	{
		var args = arguments;

		if (options === undefined || typeof options === 'object') {
			return this.each(function() {
				if (!$.data(this, 'plugin_' + pluginName))
					$.data(this, 'plugin_' + pluginName, new Plugin(this, options));
			});
		}
		else if (typeof options === 'string' && options[0] !== '_') {
			return this.each(function() {
				var instance = $.data(this, 'plugin_' + pluginName);
				if (instance instanceof Plugin && typeof instance[options] === 'function')
					instance[options].apply(instance, Array.prototype.slice.call(args, 1));
			});
		}
	};

})(jQuery, window, document);




// HTML ///////////////////////////////////////////////


function htmlCoolText()
{
	$.each($("body").find("[ct-sequence], [ct-mouseover], [ct-mouseout], [ct-click]"), function(idx, val) {

		var seq = $(this).attr("ct-sequence");
		var over = $(this).attr("ct-mouseover");
		var out = $(this).attr("ct-mouseout");
		var click = $(this).attr("ct-click");
		var config = $(this).attr("ct-config");

		var sequence = [];
		if (typeof seq !== 'undefined')
		{
			seq = seq.replace(/\s+/g, '').split("|");
			for(var i=0; i<seq.length; i++) {

				var params = seq[i].replace(/\s+/g, '').split(",");

				sequence[i] = {
					action:"animation",
					stop:false,
					animation:params[0],
					elements:params[1],
					speed:params[2],
					stagger:params[3],
					delay:params[4],
					order:params[5],
					css:{color:params[6]}
				};
			}
		}
		if (typeof over !== 'undefined')
		{
			over = over.replace(/\s+/g, '').split(",");
			var over_obj = {
				action:"animation",
         	animation:over[0],
				elements:over[1],
				speed:over[2],
				stagger:over[3],
				delay:over[4],
				order:over[5],
				overwrite:over[6],
				css:{color:over[7]}
			}
		}
		if (typeof out !== 'undefined')
		{
			out = out.replace(/\s+/g, '').split(",");
			var out_obj = {
				action:"animation",
         	animation:out[0],
				elements:out[1],
				speed:out[2],
				stagger:out[3],
				delay:out[4],
				order:out[5],
				overwrite:out[6],
				css:{color:out[7]}
			}
		}
		if (typeof click !== 'undefined')
		{
			click = click.replace(/\s+/g, '').split(",");
			var click_obj = {
				action:"animation",
         	animation:click[0],
				elements:click[1],
				speed:click[2],
				stagger:click[3],
				delay:click[4],
				order:click[5],
				overwrite:click[6],
				css:{color:click[7]}
			}
		}

		if (typeof config !== 'undefined')
		{
			var cycle = (config.indexOf("cycle") >= 0);
			var pause_on_mouseover = (config.indexOf("pause-on-mouseover") >= 0);
			var resume_on_mouseout = (config.indexOf("resume-on-mouseout") >= 0);
			var wait_for_load = (config.indexOf("wait-for-load") >= 0);
		}

		$(this).cooltext({
         pauseOnMouseOver:pause_on_mouseover,
         resumeOnMouseOut:resume_on_mouseout,
         cycle:cycle,
         waitForLoad:wait_for_load,
         onMouseOver:over_obj,
         onMouseOut:out_obj,
         onClick:click_obj,
         sequence:sequence
   	});
	});
};


if (typeof tmAutoStart === 'undefined')
{
	$(document).ready(function() {
		htmlCoolText();
	});
}
