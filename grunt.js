module.exports = function(grunt) {

  grunt.initConfig({
    project : {
      coffee_src : 'src/coffee/**/*.coffee',
      site_src: ['site/**/*.html', 'site/**/*.css'],
      lib : ['site/lib/*.js'],
      build_dir : "build/"
    },
    concat: {
      lib: {
        src:  '<config:project.lib>',
        dest: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/lib_all.js" %>'
      },
      all: {
        src: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/*.js" %>',
        dest: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/kaffeemaschine_all.js" %>'
      }
    },
    min: {
      all: {
        src:  '<%= grunt.config("project.build_dir") '
                          + ' + "javascript/kaffeemaschine_all.js"%>',
        dest: '<%= grunt.config("project.build_dir") '
                          + ' + "javascript/kaffeemaschine_all.js.min"%>'
      }
    },
    watch: {
      files: '<config:project.coffee_src>',
      tasks: 'build:site:nomin'
    }
  });

grunt.registerTask('build:coffee', 'Compile coffeescript to javascript.',
  function() {
    var files = grunt.file.expandFiles(grunt.config("project.coffee_src"));
    var target_dir = grunt.config('project.build_dir') + 'javascript/';

    var coffee = require('coffee-script');
    var path = require('path');
    files.forEach(function(filepath) {
        var target_name = path.basename(filepath).replace(/\.coffee$/, '.js');
        var target_path = target_dir + target_name;
        try {
          grunt.log.write("Compile " + filepath + " to "
                                        + target_path + "... ");
          var js = coffee.compile(grunt.file.read(filepath));
        } catch(e) {
          grunt.log.writeln("Error: " + e);
          throw e;
        }
        if (js) {
          grunt.file.write(target_path, js);
          grunt.log.writeln("Success");
        }
    });
  });

var build_site_requirements = 'build:coffee concat:lib concat:all';
grunt.registerTask('build-site', 'Generate html site.',
  function() {
    this.requires(build_site_requirements);

    var build_dir = grunt.config('project.build_dir');
    var files = grunt.file.expandFiles(grunt.config("project.site_src"));


    // copy html + css files
    var copy = function(src, dest) {
      grunt.log.write('Copy ' + src + ' to ' + dest + '... ');
      try {
        grunt.file.copy(src, dest);
        grunt.log.writeln('Success');
      } catch(e) {
        grunt.log.writeln('Error: ' + e);
        throw e;
      }
    }

    files.forEach(function(filepath) {
      var target_path = build_dir + filepath;
      copy(filepath, target_path);
    });

    var srcpath = build_dir + 'javascript/kaffeemaschine_all.js';
    if (this.flags.min) {
       srcpath += '.min';
    }

    copy(srcpath, build_dir + 'site/lib/kaffeemaschine_all.js');
});

grunt.registerTask('build:site', build_site_requirements + ' min build-site:min');
grunt.registerTask('build:site:nomin', build_site_requirements + ' build-site');

grunt.registerTask('clean', 'Delete all temporary files.', function() {
  var fs = require('fs')
  var build_dir = grunt.config("project.build_dir");

  var delete_path = function(path) {
    grunt.log.write('Delete ' + path + '... ');
    try {
      if(fs.statSync(path).isFile()) {
        fs.unlinkSync(path);
      } else {
        fs.rmdirSync(path);
      }
      grunt.log.writeln('Success');
    } catch(e) {
      grunt.log.writeln('Error: ' + e);
      throw e;
    }
  }

  var files = grunt.file.expandFiles(build_dir + '**/*');
  files.forEach(function(filepath) {
    delete_path(filepath);
  });

  var dirs = grunt.file.expandDirs(build_dir + '**/*');
  dirs.reverse().forEach(function(dirpath) {
    delete_path(dirpath);
  });

  delete_path(build_dir);
});

  grunt.registerTask('default', 'build:site');
};
