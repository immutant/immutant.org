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


  add_matrix_build: function(build, ignored) {
    var self = this;

    column = $( '.build-summary.build-' + build.number ).find( 'td.1_6_0' );
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

    self.populate_artifacts( build );

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
    }

  },

  populate_artifacts: function(build) {
      var self = this;

      if ( build.result != 'SUCCESS' ) {
          return;
      }

      // Docs

      $( '.build-summary.build-' + build.number ).find( 'td.docs' ).
          append('<a href="https://projectodd.ci.cloudbees.com/job/immutant2-incremental/' + build.number + '/artifact/target/apidocs/index.html">Browse API' + (build.number > 311 ? ' & Guides' : '') + '</a>');
  },


  format_size: function(val) {
      return Math.round(val/1024/1024) + " mb";
  },

  create_build_row: function(build) {
    var self = this;
    row = $( '<tr class="build-summary build-' + build.number + '"/>' ).append(
            $( '<td class="build-info first"/>' ).append(
              $( '<span class="number"><a href="' + build.url + '">' + build.number + '</a></span>' ),
              $( '<span class="date">' + self.build_date( build ) + " " + self.build_time( build ) + '</span>' )
            ),
            $( '<td class="docs"/>' ),
            $( '<td class="git"/>' ),
            $( '<td rowspan="2" class="matrix 1_6_0 matrix-unknown"/>' )
          );

    var sha = self.build_sha1(build)
    if (sha) {
      row.find('td.git').append(self.build_sha1_short(build) + ': ',
          $( '<a href="https://github.com/immutant/immutant/commits/' + sha + '">Commits</a>' ),
          " / ",
          $( '<a href="https://github.com/immutant/immutant/tree/' + sha + '">Tree</a>' ))
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
    if (build.actions) {
        return build.actions.reduce(function(found, action) {
            if (!found && action.lastBuiltRevision) {
                return action.lastBuiltRevision.SHA1
            } else {
                return found
            }
        }, null)
    }
    return null;
  },

  build_sha1_short: function(build) {
    var sha = this.build_sha1(build)
    if (sha) {
      return sha.substring(0,8);
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

j = new Jenkins( renderer, '/builds/build-info', 'immutant2-incremental',
                 [['', '1_6_0']] );
