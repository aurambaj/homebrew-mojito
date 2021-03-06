class MojitoCli < Formula
  desc "Mojito CLI is the command line interface of Mojito: a continuous localization platform"
  homepage "http://www.mojito.global"
  
  url "https://github.com/box/mojito/releases/download/v0.56/mojito-cli-0.56.jar"
  sha256 "27218fdfc56cbcf03255e97ca31b637fc26c59690921a259ec4ad29a15fd570f"

  head "git@github.com:box/mojito.git", :using => :git, :branch => "master"

  depends_on :java => "1.7+"

  if build.head?
    depends_on "maven" => :build
  end

  def install
 
    if build.head?
      # build the jar
      system "mvn package -DskipTests -P!frontend"
      libexec.install Dir["cli/target/mojito-cli-*.jar"]
    else
      # use downloaded jar
      libexec.install Dir["mojito-cli-*.jar"]         
    end

    # Create the shell script to execute mojito cli
    (bin/"mojito").write <<-EOS.undent
          #!/bin/sh
          java -Dspring.config.location=#{etc}/mojito/cli/ -jar #{libexec}/mojito-cli-*.jar "$@"
    EOS

    # Create the shell script to bash complete mojito cli
    (buildpath/"mojito").write <<-EOS.undent
      _mojito()
      {
        local cur prev mojito_commands
        mojito_commands="-h --help demo-create drop-export drop-import drop-xliff-import leveraging-copy-tm pull push \
        repo-create repo-delete repo-update tm-export tm-import user-create user-delete user-update"
        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}
        if [ ${#COMP_WORDS[@]} == 2 ]; then
          case "$cur" in
            *) COMPREPLY=( $( compgen -W '$mojito_commands' -- $cur ) );;
          esac
        fi
      } && complete -F _mojito mojito
    EOS

    bash_completion.install Dir["#{buildpath}/mojito"]

  end
end
