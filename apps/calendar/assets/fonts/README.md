Noto Sans Malayalam (Regular, Bold), hinted TTF, from
https://github.com/notofonts/notofonts.github.io/tree/main/fonts/NotoSansMalayalam
Licensed under the SIL Open Font License 1.1, see OFL.txt.

Roboto (Regular, Medium, Bold), from the Flutter SDK's material_fonts
(bin/cache/artifacts/material_fonts), subset to Latin, punctuation, arrows
and the rupee sign with fontTools:

    pyftsubset roboto-regular.ttf --layout-features='*' \
      --unicodes="U+0020-007E,U+00A0-017F,U+2000-206F,U+20B9,U+2190-2193,U+2212,U+2215,U+FFFD" \
      --output-file=Roboto-Regular.ttf

Licensed under the Apache License 2.0, see Roboto-LICENSE.txt. Bundled so
the web app draws Latin text without fetching Roboto from Google Fonts.
