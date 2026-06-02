user="root"
server="dev1.innoventum.fi"
path="/var/www/ecounityproject.app/www/html/app/"
baseHref="/app/"
echo building ...
# Build the web version of the app
# append possible user input parameters to the build command
# e.g. --release or --profile
# read the arguments
#if no arguments are given, build the release version
if [ $# -eq 0 ]; then
    echo "Building release version"
    flutter build web --release --base-href "$baseHref"
fi
while [ "$1" != "" ]; do
    case $1 in
        -r | --release )        shift
                                echo "Building release version"
                                flutter build web --release --base-href "$baseHref"

                                ;;
        -p | --profile )        shift
                                echo "Building profile version"
                                flutter build web --profile --base-href "$baseHref"

                                ;;
        * )                     echo "Invalid argument: $1"
                                exit 1
    esac
    shift
done
echo build done.
echo copying to server ...
# Copy the web build to the server using rsync
rsync_result=$(rsync -avz build/web/ "$user"@"$server":"$path")
echo "$rsync_result"
#echo current time
echo done at "$(date +"%Y-%m-%d %T")"



