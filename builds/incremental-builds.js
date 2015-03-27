renderer = {
  add_build: function(build) {
    var self = this;
    row = self.create_build_row( build );

    row[row.length-1].addClass( 'divide' );

    $.each( row, function(i,r) {
      $('#builds tr.load').hide();
      $( '#builds' ).append( row[i] );
    } );

    if ( self.lastSuccessfulBuild && ( self.lastSuccessfulBuild.number == build.number ) ) {
      $('#latest-stable tr.load').hide();
      $( '#latest-stable' ).append( row[0].clone() );
    }

  },


  add_matrix_build: function(build, label) {
    var self = this;
    column = $( '.build-summary.build-' + build.number ).find( 'td.' + label );
    column.removeClass( 'matrix-unknown' );

    if ( build.result == 'SUCCESS' ) {
      column.addClass( 'matrix-success' );
      column.append(
        $( '<a href="' + build.url + '/console' + '" class="status">Passed</a>' )
      );
    } else if ( build.result == 'FAILURE' ) {
      column.addClass( 'matrix-failure' );
      column.append(
        $( '<a href="' + build.url + '/console' + '" class="status">Failed</a>' )
      );
    }  else if ( build.result == 'ABORTED' ) {
      column.addClass( 'matrix-aborted' );
      column.append(
        $( '<a href="' + build.url + '/console' + '" class="status">Aborted</a>' )
      );
    }  else if ( build.building ) {
      column.addClass( 'matrix-building' );
      column.append(
        $( '<a href="' + build.url + '/console' + '" class="status"><em>Building</em></a>' )
      );
    }

    var duration;

    if ( build.building ) {
      duration = new Date() - new Date( build.timestamp );
    } else {
      duration = build.duration;
    }

    duration = Math.floor( duration / ( 60 * 1000 ) );

    column.append( '<span class="duration">: ' + duration + ' min</span>' );

    if ( build.building ) {
      column.append( $( '<ul class="links"/>' ).append(
          $( '<li><a href="' + build.url + '../ws/integration-tests/target/integ-dist/jboss/standalone/log/boot.log">boot.log</a></li>'  ),
          $( '<li><a href="' + build.url + '../ws/integration-tests/target/integ-dist/jboss/standalone/log/server.log">server.log</a></li>'  )
        )
      );
    }


    if ( label == '1_6_0' ) {
      self.populate_artifacts( build );
      self.update_artifacts( build );
    }

    row = $( '.build-' + build.number );

    if ( row.find( '.matrix' ).size() == row.find( '.matrix-success' ).size() ) {
      row.addClass( 'build-success' );
    }
    if ( row.find( '.matrix-failure' ).size() > 0 ) {
      row.addClass( 'build-failure' );
    }
    if ( row.find( '.matrix' ).size() == row.find( '.matrix-aborted' ).size() ) {
      row.addClass( 'build-aborted' );
      row.find( 'td *' ).hide();
      row.find( 'td .number' ).show();
      row.find( 'td .number a' ).show();
      $( '.build-' + build.number + '.build-details td *' ).hide();
      //$( '.build-' + build.number + '.build-details' ).addClass( 'hidden' );
    }

  },

  populate_artifacts: function(build) {
      var self = this;

      if ( build.result != 'SUCCESS' ) {
          return;
      }

      // Docs

      docs_column = $( '.build-summary.build-' + build.number ).find( 'td.docs' );
      ul = $( '<ul/>' );
      ul.append( $( '<li class="artifact"><a href="/builds/' + build.number + '/html-docs/index.html">Browse Manual</a></li>' ) );
      ul.append( $( '<li class="artifact"><a href="/builds/' + build.number + '/html-docs/apidoc/index.html">Browse Clojure API</a></li>' ) );
      // ul.append( $( '<li class="artifact newdocs"><a href="/builds/' + build.number + '/javadocs/">Java API Docs</a></li>' ) );
      docs_column.append( ul );
  },


  format_size: function(val) {
      return Math.round(val/1024/1024) + " mb";
  },

  update_artifacts: function(build) {
    var self = this;

    if ( build.result != 'SUCCESS' ) {
      return;
    }

       $.getJSON( '/builds/' + build.number + '/build-metadata.json',
             function(data) {
                 binary_column = $( '.build-summary.build-' + build.number ).find( 'td.binary' );
                 ul = $( '<ul/>' );
                 if (data.slim_dist_size > 0) {
                     ul.append( $( '<li class="artifact"><a href="/builds/' + build.number + '/immutant-dist-slim.zip">Slim Build ZIP</a> (' + self.format_size(data.slim_dist_size) + ')</li>' ) );
                     if (data.full_dist_size > 0) {
                         ul.append( $( '<li class="artifact"><a href="/builds/' + build.number + '/immutant-dist-full.zip">Full Build ZIP</a> (' + self.format_size(data.full_dist_size) + ')</li>' ) );
                     }
                 } else {
                     ul.append( $( '<li class="artifact"><a href="/builds/' + build.number + '/immutant-dist-bin.zip">Full Build ZIP</a> (' + self.format_size(data.dist_size) + ')</li>' ) );
                 }
                 binary_column.append(ul);
           } );
  },

  create_build_row: function(build) {
    var self = this;
    row = $( '<tr class="build-summary build-' + build.number + '"/>' ).append(
            $( '<td class="build-info first"/>' ).append(
              $( '<span class="number"><a href="' + build.url + '">' + build.number + '</a></span>' ),
              $( '<span class="date">' + self.build_date( build ) + '</span>' ),
              $( '<span class="time">' + self.build_time( build ) + '</span>' )
            ),
            $( '<td class="binary"/>' ),
            $( '<td class="docs"/>' ),
            $( '<td class="git"/>' ),
            $( '<td rowspan="2" class="matrix 1_4_0 matrix-unknown"/>' ),
            $( '<td rowspan="2" class="matrix 1_5_1 matrix-unknown"/>' ),
            $( '<td rowspan="2" class="matrix 1_6_0 matrix-unknown"/>' )
          );

    if ( self.build_sha1( build ) ) {
      row.find( '.build-info' ).append(
        $( '<span class="sha1"/>' ).append(
          $('<a href="https://github.com/immutant/immutant/commits/' + self.build_sha1( build )+ '">' + self.build_sha1_short( build ) + '</a>' )
        )
      );
      row.find( '.git').append(
        $( '<ul/>' ).append(
          $( '<li/>').append(
            $( '<a href="https://github.com/immutant/immutant/commits/' + self.build_sha1( build ) + '">Commits</a>' )
          ),
          $( '<li/>').append(
            $( '<a href="https://github.com/immutant/immutant/tree/' + self.build_sha1( build )+ '">Tree</a>' )
          )
        )
      );
    }

    details_row = $( '<tr class="build-details build-' + build.number + '"/>' ).append(
      $( '<td class="first" colspan="7"/>' )
    );

    if ( build.result == 'FAILURE' ) {
      if ( build.culprits.length > 0 ) {
        names = $.map( build.culprits, function(each,i) {
          return each.fullName;
        } );
        details_row.find( 'td' ).append( "Possible culprits: " + names.join( ', ' ) );
      }
    }

    if ( build.building ) {
      row.addClass( 'build-building' );
      details_row.addClass( 'build-building' );
      $('#build-currently-building').append( $( '<span>A build is currently in progress.</span>' ) );
    }

    return [ row, details_row ];
  },

  build_date: function(build) {
     date = new Date( build.timestamp );
     return date.format( "dd mmmm yyyy" );
  },

  build_time: function(build) {
     date = new Date( build.timestamp );
     return date.format( "HH:MM" ) + ' US Eastern';
  },

  build_sha1: function(build) {
    if ( build.actions && build.actions.length >= 3 && build.actions[2].lastBuiltRevision ) {
      return build.actions[2].lastBuiltRevision.SHA1;
    }
    return null;
  },

  build_sha1_short: function(build) {
    if ( build.actions && build.actions.length >= 3 ) {
      return build.actions[2].lastBuiltRevision.SHA1.substring(0,8);
    }
    return null;
  },

  locate_artifact: function(build, filename) {
    result = null;
    var filename_regexp = new RegExp( filename );
    $.each( build.artifacts, function(i, artifact) {
      if ( artifact.relativePath.match( filename_regexp )  ) {
        result = artifact;
        return false;
      }
    } );
    return result;
  }

};

j = new Jenkins( renderer, '/builds/build-info', 'immutant-incremental',
                 [['clojure_compat_version=1.4.0,label=m1.large', '1_4_0'],
                  ['clojure_compat_version=1.5.1,label=m1.large', '1_5_1'],
                  ['clojure_compat_version=1.6.0,label=m1.large', '1_6_0']] );
