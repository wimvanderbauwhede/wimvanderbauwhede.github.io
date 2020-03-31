## Example config

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