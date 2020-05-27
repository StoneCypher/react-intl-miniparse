
import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs    from 'rollup-plugin-commonjs';
import replace     from 'rollup-plugin-replace';





const config = {

  input: 'build/es6/src/ts/rim.js',

  output: {
    file    : 'build/rim.bundle.js',
    format  : 'cjs',
    name    : 'rim',
    exports : 'named'
  },

  plugins : [

    nodeResolve({
      mainFields     : ['module', 'main'],
      browser        : true,
      extensions     : [ '.js', '.json', '.ts', '.tsx' ],
      preferBuiltins : false
    }),

    commonjs(),

    replace({
      'process.env.NODE_ENV' : JSON.stringify( 'production' )
    })

  ]

};





export default config;