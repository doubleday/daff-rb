#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Coopy 
    
    def initialize
      @extern_preference = false
      @format_preference = nil
      @delim_preference = nil
      @output_format = "copy"
      @nested_output = false
      @order_set = false
      @order_preference = false
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :format_preference
    attr_accessor :delim_preference
    attr_accessor :extern_preference
    attr_accessor :output_format
    attr_accessor :nested_output
    attr_accessor :order_set
    attr_accessor :order_preference
    attr_accessor :io
    attr_accessor :mv
    
    def check_format(name)
      return @format_preference if @extern_preference
      ext = ""
      pt = name.rindex(".",nil || 0) || -1
      if pt >= 0 
        ext = name[pt + 1..-1] #.to_lower_case
        case(ext)
        when "json"
          @format_preference = "json"
        when "ndjson"
          @format_preference = "ndjson"
        when "csv"
          @format_preference = "csv"
          @delim_preference = ","
        when "tsv"
          @format_preference = "csv"
          @delim_preference = "\t"
        when "ssv"
          @format_preference = "csv"
          @delim_preference = ";"
        when "sqlite3"
          @format_preference = "sqlite"
        when "sqlite"
          @format_preference = "sqlite"
        else
          ext = ""
        end
      end
      @nested_output = @format_preference == "json" || @format_preference == "ndjson"
      @order_preference = !@nested_output
      return ext
    end
    
    def set_format(name)
      @extern_preference = false
      self.check_format("." + _hx_str(name))
      @extern_preference = true
    end
    
    def save_table(name,t)
      self.set_format(@output_format) if @output_format != "copy"
      txt = ""
      self.check_format(name)
      if @format_preference == "csv" 
        csv = ::Coopy::Csv.new(@delim_preference)
        txt = csv.render_table(t)
      elsif @format_preference == "ndjson" 
        txt = ::Coopy::Ndjson.new(t).render
      elsif @format_preference == "sqlite" 
        @io.write_stderr("! Cannot yet output to sqlite, aborting\n")
        return false
      else 
        value = ::Coopy::Coopy.jsonify(t)
        txt = ::Haxe::Format::JsonPrinter._print(value,nil,"  ")
      end
      return self.save_text(name,txt)
    end
    
    def save_text(name,txt)
      if name != "-" 
        @io.save_content(name,txt)
      else 
        @io.write_stdout(txt)
      end
      return true
    end
    
    def load_table(name)
      txt = @io.get_content(name)
      ext = self.check_format(name)
      if ext == "sqlite" 
        sql = @io.open_sqlite_database(name)
        if sql == nil 
          @io.write_stderr("! Cannot open database, aborting\n")
          return nil
        end
        helper = ::Coopy::SqliteHelper.new
        names = helper.get_table_names(sql)
        if names == nil 
          @io.write_stderr("! Cannot find database tables, aborting\n")
          return nil
        end
        if names.length == 0 
          @io.write_stderr("! No tables in database, aborting\n")
          return nil
        end
        tab = ::Coopy::SqlTable.new(sql,::Coopy::SqlTableName.new(names[0]),helper)
        return tab
      end
      if ext == "ndjson" 
        t = ::Coopy::SimpleTable.new(0,0)
        ndjson = ::Coopy::Ndjson.new(t)
        ndjson.parse(txt)
        return t
      end
      begin
        json = ::Haxe::Format::JsonParser.new(txt).parse_rec
        @format_preference = "json"
        t1 = ::Coopy::Coopy.json_to_table(json)
        raise hx_raise("JSON failed") if t1 == nil
        return t1
      rescue => e
        e = hx_rescued(e)
        raise hx_raise(e) if ext == "json"
      end if ext == "json" || ext == ""
      @format_preference = "csv"
      csv = ::Coopy::Csv.new(@delim_preference)
      output = ::Coopy::SimpleTable.new(0,0)
      csv.parse_table(txt,output)
      output.trim_blank if output != nil
      return output
    end
    
    attr_accessor :status
    attr_accessor :daff_cmd
    
    def command(io,cmd,args)
      r = 0
      r = io.command(cmd,args) if io.async
      if r != 999 
        io.write_stdout("$ " + _hx_str(cmd))
        begin
          _g = 0
          while(_g < args.length) 
            arg = args[_g]
            _g+=1
            io.write_stdout(" ")
            spaced = (arg.index(" ",nil || 0) || -1) >= 0
            io.write_stdout("\"") if spaced
            io.write_stdout(arg)
            io.write_stdout("\"") if spaced
          end
        end
        io.write_stdout("\n")
      end
      r = io.command(cmd,args) if !io.async
      return r
    end
    
    def install_git_driver(io,formats)
      r = 0
      if @status == nil 
        @status = {}
        @daff_cmd = ""
      end
      key = "hello"
      if !@status.include?(key) 
        io.write_stdout("Setting up git to use daff on")
        begin
          _g = 0
          while(_g < formats.length) 
            format = formats[_g]
            _g+=1
            io.write_stdout(" *." + _hx_str(format))
          end
        end
        io.write_stdout(" files\n")
        @status[key] = r
      end
      key = "can_run_git"
      if !@status.include?(key) 
        r = self.command(io,"git",["--version"])
        return r if r == 999
        @status[key] = r
        if r != 0 
          io.write_stderr("! Cannot run git, aborting\n")
          return 1
        end
        io.write_stdout("- Can run git\n")
      end
      daffs = ["daff","daff.rb","daff.py"]
      if @daff_cmd == "" 
        begin
          _g1 = 0
          while(_g1 < daffs.length) 
            daff = daffs[_g1]
            _g1+=1
            key1 = "can_run_" + _hx_str(daff)
            if !@status.include?(key1) 
              r = self.command(io,daff,["version"])
              return r if r == 999
              @status[key1] = r
              if r == 0 
                @daff_cmd = daff
                io.write_stdout("- Can run " + _hx_str(daff) + " as \"" + _hx_str(daff) + "\"\n")
                break
              end
            end
          end
        end
        if @daff_cmd == "" 
          io.write_stderr("! Cannot find daff, is it in your path?\n")
          return 1
        end
      end
      begin
        _g2 = 0
        while(_g2 < formats.length) 
          format1 = formats[_g2]
          _g2+=1
          key = "have_diff_driver_" + _hx_str(format1)
          if !@status.include?(key) 
            r = self.command(io,"git",["config","--global","--get","diff.daff-" + _hx_str(format1) + ".command"])
            return r if r == 999
            @status[key] = r
          end
          have_diff_driver = @status[key] == 0
          key = "add_diff_driver_" + _hx_str(format1)
          if !@status.include?(key) 
            if !have_diff_driver 
              r = self.command(io,"git",["config","--global","diff.daff-" + _hx_str(format1) + ".command",_hx_str(@daff_cmd) + " diff --color --git"])
              return r if r == 999
              io.write_stdout("- Added diff driver for " + _hx_str(format1) + "\n")
            else 
              r = 0
              io.write_stdout("- Already have diff driver for " + _hx_str(format1) + ", not touching it\n")
            end
            @status[key] = r
          end
          key = "have_merge_driver_" + _hx_str(format1)
          if !@status.include?(key) 
            r = self.command(io,"git",["config","--global","--get","merge.daff-" + _hx_str(format1) + ".driver"])
            return r if r == 999
            @status[key] = r
          end
          have_merge_driver = @status[key] == 0
          key = "name_merge_driver_" + _hx_str(format1)
          if !@status.include?(key) 
            if !have_merge_driver 
              r = self.command(io,"git",["config","--global","merge.daff-" + _hx_str(format1) + ".name","daff tabular " + _hx_str(format1) + " merge"])
              return r if r == 999
            else 
              r = 0
            end
            @status[key] = r
          end
          key = "add_merge_driver_" + _hx_str(format1)
          if !@status.include?(key) 
            if !have_merge_driver 
              r = self.command(io,"git",["config","--global","merge.daff-" + _hx_str(format1) + ".driver",_hx_str(@daff_cmd) + " merge --output %A %O %A %B"])
              return r if r == 999
              io.write_stdout("- Added merge driver for " + _hx_str(format1) + "\n")
            else 
              r = 0
              io.write_stdout("- Already have merge driver for " + _hx_str(format1) + ", not touching it\n")
            end
            @status[key] = r
          end
        end
      end
      if !io.exists(".git/config") 
        io.write_stderr("! This next part needs to happen in a git repository.\n")
        io.write_stderr("! Please run again from the root of a git repository.\n")
        return 1
      end
      attr = ".gitattributes"
      txt = ""
      post = ""
      if !io.exists(attr) 
        io.write_stdout("- No .gitattributes file\n")
      else 
        io.write_stdout("- You have a .gitattributes file\n")
        txt = io.get_content(attr)
      end
      need_update = false
      begin
        _g3 = 0
        while(_g3 < formats.length) 
          format2 = formats[_g3]
          _g3+=1
          if (txt.index("*." + _hx_str(format2),nil || 0) || -1) >= 0 
            io.write_stderr("- Your .gitattributes file already mentions *." + _hx_str(format2) + "\n")
          else 
            post += "*." + _hx_str(format2) + " diff=daff-" + _hx_str(format2) + "\n"
            post += "*." + _hx_str(format2) + " merge=daff-" + _hx_str(format2) + "\n"
            io.write_stdout("- Placing the following lines in .gitattributes:\n")
            io.write_stdout(post)
            txt += "\n" if txt != "" && !need_update
            txt += post
            need_update = true
          end
        end
      end
      io.save_content(attr,txt) if need_update
      io.write_stdout("- Done!\n")
      return 0
    end
    
    public
    
    def coopyhx(io)
      args = io.args
      return ::Coopy::Coopy.keep_around if args[0] == "--keep"
      more = true
      output = nil
      css_output = nil
      fragment = false
      pretty = true
      inplace = false
      git = false
      color = false
      flags = ::Coopy::CompareFlags.new
      flags.always_show_header = true
      while(more) 
        more = false
        begin
          _g1 = 0
          _g = args.length
          while(_g1 < _g) 
            i = _g1
            _g1+=1
            tag = args[i]
            if tag == "--output" 
              more = true
              output = args[i + 1]
              args.slice!(i,2)
              break
            elsif tag == "--css" 
              more = true
              fragment = true
              css_output = args[i + 1]
              args.slice!(i,2)
              break
            elsif tag == "--fragment" 
              more = true
              fragment = true
              args.slice!(i,1)
              break
            elsif tag == "--plain" 
              more = true
              pretty = false
              args.slice!(i,1)
              break
            elsif tag == "--all" 
              more = true
              flags.show_unchanged = true
              args.slice!(i,1)
              break
            elsif tag == "--act" 
              more = true
              flags.acts = {} if flags.acts == nil
              begin
                flags.acts[args[i + 1]] = true
                true
              end
              args.slice!(i,2)
              break
            elsif tag == "--context" 
              more = true
              context = args[i + 1].to_i
              flags.unchanged_context = context if context >= 0
              args.slice!(i,2)
              break
            elsif tag == "--inplace" 
              more = true
              inplace = true
              args.slice!(i,1)
              break
            elsif tag == "--git" 
              more = true
              git = true
              args.slice!(i,1)
              break
            elsif tag == "--unordered" 
              more = true
              flags.ordered = false
              flags.unchanged_context = 0
              @order_set = true
              args.slice!(i,1)
              break
            elsif tag == "--ordered" 
              more = true
              flags.ordered = true
              @order_set = true
              args.slice!(i,1)
              break
            elsif tag == "--color" 
              more = true
              color = true
              args.slice!(i,1)
              break
            elsif tag == "--input-format" 
              more = true
              self.set_format(args[i + 1])
              args.slice!(i,2)
              break
            elsif tag == "--output-format" 
              more = true
              @output_format = args[i + 1]
              args.slice!(i,2)
              break
            elsif tag == "--id" 
              more = true
              flags.ids = Array.new if flags.ids == nil
              flags.ids.push(args[i + 1])
              args.slice!(i,2)
              break
            elsif tag == "--ignore" 
              more = true
              flags.columns_to_ignore = Array.new if flags.columns_to_ignore == nil
              flags.columns_to_ignore.push(args[i + 1])
              args.slice!(i,2)
              break
            elsif tag == "--index" 
              more = true
              flags.always_show_order = true
              flags.never_show_order = false
              args.slice!(i,1)
              break
            end
          end
        end
      end
      cmd = args[0]
      if args.length < 2 
        if cmd == "version" 
          io.write_stdout(_hx_str(::Coopy::Coopy.version) + "\n")
          return 0
        end
        if cmd == "git" 
          io.write_stdout("You can use daff to improve git's handling of csv files, by using it as a\ndiff driver (for showing what has changed) and as a merge driver (for merging\nchanges between multiple versions).\n")
          io.write_stdout("\n")
          io.write_stdout("Automatic setup\n")
          io.write_stdout("---------------\n\n")
          io.write_stdout("Run:\n")
          io.write_stdout("  daff git csv\n")
          io.write_stdout("\n")
          io.write_stdout("Manual setup\n")
          io.write_stdout("------------\n\n")
          io.write_stdout("Create and add a file called .gitattributes in the root directory of your\nrepository, containing:\n\n")
          io.write_stdout("  *.csv diff=daff-csv\n")
          io.write_stdout("  *.csv merge=daff-csv\n")
          io.write_stdout("\nCreate a file called .gitconfig in your home directory (or alternatively\nopen .git/config for a particular repository) and add:\n\n")
          io.write_stdout("  [diff \"daff-csv\"]\n")
          io.write_stdout("  command = daff diff --color --git\n")
          io.write_stderr("\n")
          io.write_stdout("  [merge \"daff-csv\"]\n")
          io.write_stdout("  name = daff tabular merge\n")
          io.write_stdout("  driver = daff merge --output %A %O %A %B\n\n")
          io.write_stderr("Make sure you can run daff from the command-line as just \"daff\" - if not,\nreplace \"daff\" in the driver and command lines above with the correct way\nto call it. Omit --color if your terminal does not support ANSI colors.")
          io.write_stderr("\n")
          return 0
        end
        io.write_stderr("daff can produce and apply tabular diffs.\n")
        io.write_stderr("Call as:\n")
        io.write_stderr("  daff [--color] [--output OUTPUT.csv] a.csv b.csv\n")
        io.write_stderr("  daff [--output OUTPUT.csv] parent.csv a.csv b.csv\n")
        io.write_stderr("  daff [--output OUTPUT.ndjson] a.ndjson b.ndjson\n")
        io.write_stderr("  daff patch [--inplace] [--output OUTPUT.csv] a.csv patch.csv\n")
        io.write_stderr("  daff merge [--inplace] [--output OUTPUT.csv] parent.csv a.csv b.csv\n")
        io.write_stderr("  daff trim [--output OUTPUT.csv] source.csv\n")
        io.write_stderr("  daff render [--output OUTPUT.html] diff.csv\n")
        io.write_stderr("  daff copy in.csv out.tsv\n")
        io.write_stderr("  daff git\n")
        io.write_stderr("  daff version\n")
        io.write_stderr("\n")
        io.write_stderr("The --inplace option to patch and merge will result in modification of a.csv.\n")
        io.write_stderr("\n")
        io.write_stderr("If you need more control, here is the full list of flags:\n")
        io.write_stderr("  daff diff [--output OUTPUT.csv] [--context NUM] [--all] [--act ACT] a.csv b.csv\n")
        io.write_stderr("     --act ACT:     show only a certain kind of change (update, insert, delete)\n")
        io.write_stderr("     --all:         do not prune unchanged rows\n")
        io.write_stderr("     --color:       highlight changes with terminal colors\n")
        io.write_stderr("     --context NUM: show NUM rows of context\n")
        io.write_stderr("     --id:          specify column to use as primary key (repeat for multi-column key)\n")
        io.write_stderr("     --ignore:      specify column to ignore completely (can repeat)\n")
        io.write_stderr("     --input-format [csv|tsv|ssv|json]: set format to expect for input\n")
        io.write_stderr("     --ordered:     assume row order is meaningful (default for CSV)\n")
        io.write_stderr("     --output-format [csv|tsv|ssv|json|copy]: set format for output\n")
        io.write_stderr("     --unordered:   assume row order is meaningless (default for json formats)\n")
        io.write_stderr("\n")
        io.write_stderr("  daff diff --git path old-file old-hex old-mode new-file new-hex new-mode\n")
        io.write_stderr("     --git:         process arguments provided by git to diff drivers\n")
        io.write_stderr("     --index:       include row/columns numbers from orginal tables\n")
        io.write_stderr("\n")
        io.write_stderr("  daff render [--output OUTPUT.html] [--css CSS.css] [--fragment] [--plain] diff.csv\n")
        io.write_stderr("     --css CSS.css: generate a suitable css file to go with the html\n")
        io.write_stderr("     --fragment:    generate just a html fragment rather than a page\n")
        io.write_stderr("     --plain:       do not use fancy utf8 characters to make arrows prettier\n")
        return 1
      end
      cmd1 = args[0]
      offset = 1
      if !Lambda.has(["diff","patch","merge","trim","render","git","version","copy"],cmd1) 
        if (cmd1.index(".",nil || 0) || -1) != -1 || (cmd1.index("--",nil || 0) || -1) == 0 
          cmd1 = "diff"
          offset = 0
        end
      end
      if cmd1 == "git" 
        types = args.slice!(offset,args.length - offset)
        return self.install_git_driver(io,types)
      end
      if git 
        ct = args.length - offset
        if ct != 7 
          io.write_stderr("Expected 7 parameters from git, but got " + _hx_str(ct) + "\n")
          return 1
        end
        git_args = args.slice!(offset,ct)
        args.slice!(0,args.length)
        offset = 0
        path = git_args[0]
        old_file = git_args[1]
        new_file = git_args[4]
        io.write_stdout("--- a/" + _hx_str(path) + "\n")
        io.write_stdout("+++ b/" + _hx_str(path) + "\n")
        args.push(old_file)
        args.push(new_file)
      end
      tool = self
      tool.io = io
      parent = nil
      if args.length - offset >= 3 
        parent = tool.load_table(args[offset])
        offset+=1
      end
      aname = args[offset]
      a = tool.load_table(aname)
      b = nil
      if args.length - offset >= 2 
        if cmd1 != "copy" 
          b = tool.load_table(args[1 + offset])
        else 
          output = args[1 + offset]
        end
      end
      if inplace 
        io.write_stderr("Please do not use --inplace when specifying an output.\n") if output != nil
        output = aname
        return 1
      end
      output = "-" if output == nil
      ok = true
      if cmd1 == "diff" 
        if !@order_set 
          flags.ordered = @order_preference
          flags.unchanged_context = 0 if !flags.ordered
        end
        flags.allow_nested_cells = @nested_output
        ct1 = ::Coopy::Coopy.compare_tables3(parent,a,b,flags)
        align = ct1.align
        td = ::Coopy::TableDiff.new(align,flags)
        o = ::Coopy::SimpleTable.new(0,0)
        td.hilite(o)
        if color 
          render = ::Coopy::TerminalDiffRender.new
          tool.save_text(output,render.render(o))
        else 
          tool.save_table(output,o)
        end
      elsif cmd1 == "patch" 
        patcher = ::Coopy::HighlightPatch.new(a,b)
        patcher.apply
        tool.save_table(output,a)
      elsif cmd1 == "merge" 
        merger = ::Coopy::Merger.new(parent,a,b,flags)
        conflicts = merger.apply
        ok = conflicts == 0
        io.write_stderr(_hx_str(conflicts) + " conflict" + _hx_str((((conflicts > 1) ? "s" : ""))) + "\n") if conflicts > 0
        tool.save_table(output,a)
      elsif cmd1 == "trim" 
        tool.save_table(output,a)
      elsif cmd1 == "render" 
        renderer = ::Coopy::DiffRender.new
        renderer.use_pretty_arrows(pretty)
        renderer.render(a)
        renderer.complete_html if !fragment
        tool.save_text(output,renderer.html)
        tool.save_text(css_output,renderer.sample_css) if css_output != nil
      elsif cmd1 == "copy" 
        tool.save_table(output,a)
      end
      if ok 
        return 0
      else 
        return 1
      end
    end
    
    
    class << self
    attr_accessor :version
    end
    @version = "1.2.6"
    
    def Coopy.compare_tables(local,remote,flags = nil)
      comp = ::Coopy::TableComparisonState.new
      comp.a = local
      comp.b = remote
      comp.compare_flags = flags
      ct = ::Coopy::CompareTable.new(comp)
      return ct
    end
    
    def Coopy.compare_tables3(parent,local,remote,flags = nil)
      comp = ::Coopy::TableComparisonState.new
      comp.p = parent
      comp.a = local
      comp.b = remote
      comp.compare_flags = flags
      ct = ::Coopy::CompareTable.new(comp)
      return ct
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def Coopy.keep_around 
      st = ::Coopy::SimpleTable.new(1,1)
      v = ::Coopy::Viterbi.new
      td = ::Coopy::TableDiff.new(nil,nil)
      idx = ::Coopy::Index.new
      dr = ::Coopy::DiffRender.new
      cf = ::Coopy::CompareFlags.new
      hp = ::Coopy::HighlightPatch.new(nil,nil)
      csv = ::Coopy::Csv.new
      tm = ::Coopy::TableModifier.new(nil)
      sc = ::Coopy::SqlCompare.new(nil,nil,nil)
      return 0
    end
    
    def Coopy.cell_for(x)
      return x
    end
    
    def Coopy.json_to_table(json)
      output = nil
      begin
        _g = 0
        _g1 = Reflect.fields(json)
        while(_g < _g1.length) 
          name = _g1[_g]
          _g+=1
          t = Reflect.field(json,name)
          columns = Reflect.field(t,"columns")
          next if columns == nil
          rows = Reflect.field(t,"rows")
          next if rows == nil
          output = ::Coopy::SimpleTable.new(columns.length,rows.length)
          has_hash = false
          has_hash_known = false
          begin
            _g3 = 0
            _g2 = rows.length
            while(_g3 < _g2) 
              i = _g3
              _g3+=1
              row = rows[i]
              if !has_hash_known 
                has_hash = true if Reflect.fields(row).length == columns.length
                has_hash_known = true
              end
              if !has_hash 
                lst = row
                begin
                  _g5 = 0
                  _g4 = columns.length
                  while(_g5 < _g4) 
                    j = _g5
                    _g5+=1
                    val = lst[j]
                    output.set_cell(j,i,::Coopy::Coopy.cell_for(val))
                  end
                end
              else 
                _g51 = 0
                _g41 = columns.length
                while(_g51 < _g41) 
                  j1 = _g51
                  _g51+=1
                  val1 = Reflect.field(row,columns[j1])
                  output.set_cell(j1,i,::Coopy::Coopy.cell_for(val1))
                end
              end
            end
          end
        end
      end
      output.trim_blank if output != nil
      return output
    end
    
    public
    
    def Coopy.main 
      io = ::Coopy::TableIO.new
      coopy1 = ::Coopy::Coopy.new
      return coopy1.coopyhx(io)
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def Coopy.show(t)
      w = t.get_width
      h = t.get_height
      txt = ""
      begin
        _g = 0
        while(_g < h) 
          y = _g
          _g+=1
          begin
            _g1 = 0
            while(_g1 < w) 
              x = _g1
              _g1+=1
              begin
                s = t.get_cell(x,y)
                txt += s.to_s
              end
              txt += " "
            end
          end
          txt += "\n"
        end
      end
      puts txt
    end
    
    def Coopy.jsonify(t)
      workbook = {}
      sheet = Array.new
      w = t.get_width
      h = t.get_height
      txt = ""
      begin
        _g = 0
        while(_g < h) 
          y = _g
          _g+=1
          row = Array.new
          begin
            _g1 = 0
            while(_g1 < w) 
              x = _g1
              _g1+=1
              v = t.get_cell(x,y)
              row.push(v)
            end
          end
          sheet.push(row)
        end
      end
      workbook["sheet"] = sheet
      return workbook
    end
    
  haxe_me ["coopy", "Coopy"]
  end

end
