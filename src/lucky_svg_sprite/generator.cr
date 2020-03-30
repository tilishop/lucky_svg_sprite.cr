class LuckySvgSprite::Generator
  getter icons : Array(String)

  def initialize(@path : String)
    @icons = Dir.glob("#{@path}/*.svg").sort
  end

  def concatenate(format : Format)
    icons.map do |icon|
      Converter.from_file(icon, format)
    end.join("\n").strip
  end

  def icon_classes
    icons.map do |icon|
      "class #{classify_from_path(icon)} < BaseSvgIcon; end"
    end
  end

  def sprite_name
    classify_from_path(@path)
  end

  def generate(format : Format)
    format.indent = 4
    <<-CODE
    # DO NOT EDIT! This file is generated by the lucky_svg_sprite shard.
    # More information available here:
    # https://github.com/tilishop/lucky_svg_sprite.cr#generating-sprites
    class SvgSprite::#{sprite_name} < BaseSvgSprite
      def render_icons : IO
        #{concatenate(format)}
      end

      #{icon_classes.join("\n  ")}
    end
    CODE
  end

  private def classify_from_path(path : String)
    path.strip
      .gsub(/\/$/, "")        # strip trailing slash
      .split('/').last        # split at path delimiter
      .gsub(/\.svg$/i, "")    # remove .svg extension
      .underscore             # enusre lowercase and underscored
      .gsub(/[\.\-\s]+/, "_") # strip common unwanted characters
      .gsub(/^_|_$/, "")      # strip leading and trailing underscores
      .camelcase              # CamelCase
      .gsub(/^\d+/, "")       # strip leading numbers
  end
end
