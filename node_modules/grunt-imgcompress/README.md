# imgcompress

> Batch Minify PNG and JPEG images, Ideas come from [grunt-contrib-imagemin](https://github.com/gruntjs/grunt-contrib-imagemin)


_Note that this is not an official Grunt plugin release! If you want to use this in a project, please be sure to follow the instructions for installing development versions, as outlined in the [Installing Grunt](http://gruntjs.com/installing-grunt) guide._


## Getting Started
This plugin requires Grunt `~0.4.0`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install imgcompress --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('imgcompress');
```




## Imgcompress task
_Run this task with the `grunt imgcompress` command._

Task targets, files and options may be specified according to the grunt [Configuring tasks](http://gruntjs.com/configuring-tasks) guide.

Minify images using [OptiPNG](http://optipng.sourceforge.net) and [jpegtran](http://jpegclub.org/jpegtran/).
### Options

#### optimizationLevel *(png only)*

Type: `Number`  
Default: `0`

Select optimization level between `0` and `7`.

> The optimization level 0 enables a set of optimization operations that require minimal effort. There will be no changes to image attributes like bit depth or color type, and no recompression of existing IDAT datastreams. The optimization level 1 enables a single IDAT compression trial. The trial chosen is what. OptiPNG thinks it’s probably the most effective. The optimization levels 2 and higher enable multiple IDAT compression trials; the higher the level, the more trials.

Level and trials:

1. 1 trial
2. 8 trials
3. 16 trials
4. 24 trials
5. 48 trials
6. 120 trials
7. 240 trials


#### progressive *(jpg only)*

Type: `Boolean`  
Default: `false`

Lossless conversion to progressive.


#### duplication 

Type: `String`  
Default: `override`

available `override`, `error`

destination file duplication, log an error message if chose `error`, override exist file and log an override message if chose `override`


#### childs
Type: `number`
Default: `30`

spawn how many child threads at most to help optimaze image


#### recurse
Type: `Boolean`
Default: `true`

recurse sub directory


#### ignores
Type: `string` or `array`
Default: `null`

ignores these files that match this, files that are not png, jpg or jpeg will be ignored automatic <br>
use [grunt.util.match](http://gruntjs.com/api/grunt.file#grunt.file.match) with the options {matchBase: true}
#### Example config

```javascript
grunt.initConfig ({
	imgcompress: {
		options: {
			optimizationLevel: 3
			progressive: true 	
			duplication: 'override'
			childs: 30		
			recurse: false 
			ignores: ['*.png']
		}
			

		dist: {
			files: {
				'tmp/bar.jpg': 'imgs/test/test.jpg',
				'tmp': ['imgs/test', 'imgs/test_1']
			}
		}
			
		dist2: {
			files: [
				{ src: 'test', dest: 'tmp' }
			]
		}
	}	
})

grunt.registerTask('default', ['imgcompress:dist']);
```

## Release History

 * 2013-06-29   v0.1.0   Initial release.

---

Task submitted by [ZhongleiQiu](http://github.com/qiu8310)

*This file was generated on Sat Jun 29 2013 10:29:41.*
