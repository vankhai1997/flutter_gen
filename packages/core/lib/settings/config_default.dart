const configDefaultYamlContent = '''
name: UNKNOWN

flutter_gen:
  # Optional
  output: lib/gen/
  # Optional
  line_length: 80

  # Optional
  integrations:
    flutter_svg: false
    flare_flutter: false
    rive: false
    lottie: false

  assets:
    # Optional
    enabled: true
    # Optional
    outputs:
      # Optional
      # Set to true if you want this package to be a package dependency
      # See: https://flutter.dev/docs/development/ui/assets-and-images#from-packages
      package_parameter_enabled: false
      # Optional
      # Available values:
      # - camel-case
      # - snake-case
      # - dot-delimiter
      style: dot-delimiter
      class_name: Assets
    exclude: []

  fonts:
    # Optional
    enabled: true
    # Optional
    outputs:
      class_name: FontFamily

  colors:
    # Optional
    enabled: true
    # Optional
    inputs: []
    # Optional
    outputs:
      class_name: ColorName
      
  localization:
    enabled: true
    sheet_id: ''
    out_dir: 'assets/langs'
    out_name: 'langs.csv'
    preserved_keywords: [
      'few',
      'many',
      'one',
      'other',
      'two',
      'zero',
      'male',
      'female',
    ]    

flutter:
  # See: https://flutter.dev/docs/development/ui/assets-and-images#specifying-assets
  assets: []
  # See: https://flutter.dev/docs/cookbook/design/fonts#2-declare-the-font-in-the-pubspec
  fonts: []
''';
