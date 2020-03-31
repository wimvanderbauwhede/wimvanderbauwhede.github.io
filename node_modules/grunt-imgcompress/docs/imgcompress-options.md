# Options

## optimizationLevel *(png only)*

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


## progressive *(jpg only)*

Type: `Boolean`  
Default: `false`

Lossless conversion to progressive.


## duplication 

Type: `String`  
Default: `override`

available `override`, `error`

destination file duplication, log an error message if chose `error`, override exist file and log an override message if chose `override`


## childs
Type: `number`
Default: `30`

spawn how many child threads at most to help optimaze image


## recurse
Type: `Boolean`
Default: `true`

recurse sub directory


## ignores
Type: `string` or `array`
Default: `null`

ignores these files that match this, files that are not png, jpg or jpeg will be ignored automatic <br>
use [grunt.util.match](http://gruntjs.com/api/grunt.file#grunt.file.match) with the options {matchBase: true}