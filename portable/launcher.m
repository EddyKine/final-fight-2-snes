#import <Cocoa/Cocoa.h>
#include <unistd.h>
#include <fcntl.h>
static void fail(NSString *message) {
 fprintf(stderr,"%s\n",message.UTF8String);
 if(!getenv("PORT_HEADLESS")){[NSApplication sharedApplication];NSAlert *a=[NSAlert new];a.messageText=@"Final Fight 2";a.informativeText=message;[a runModal];}exit(1);
}
int main(int argc,char **argv){@autoreleasepool{
 NSFileManager *fm=NSFileManager.defaultManager;
 NSString *resources=NSBundle.mainBundle.resourcePath;
 const char *override=getenv("PORT_DATA_DIR");
 NSString *data=override?@(override):[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/EddyKine/Final Fight 2"];
 if(!data.isAbsolutePath)fail(@"La carpeta de datos debe ser absoluta.");
 NSError *err=nil;
 for(NSString *dir in @[@"",@"saves",@"logs",@"tmp",@"cache"])
  if(![fm createDirectoryAtPath:[data stringByAppendingPathComponent:dir] withIntermediateDirectories:YES attributes:nil error:&err])fail(err.localizedDescription);
 // Refresh the resource link after moving the app; user files stay in data.
 NSString *link=[data stringByAppendingPathComponent:@"assets"];
 if([fm destinationOfSymbolicLinkAtPath:link error:nil])[fm removeItemAtPath:link error:nil];
 if(![fm fileExistsAtPath:link]&&![fm createSymbolicLinkAtPath:link withDestinationPath:[resources stringByAppendingPathComponent:@"assets"] error:&err])fail(err.localizedDescription);
 for(NSString *name in @[@"config.ini",@"keybinds.ini"]){NSString *dst=[data stringByAppendingPathComponent:name];if(![fm fileExistsAtPath:dst]&&![fm copyItemAtPath:[resources stringByAppendingPathComponent:name] toPath:dst error:&err])fail(err.localizedDescription);}
 // Preserve existing preferences while retiring the two replaced presets.
 NSString *configPath=[data stringByAppendingPathComponent:@"config.ini"];
 NSString *config=[NSString stringWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:&err];
 if(!config)fail(err.localizedDescription);
 NSString *updated=[[config stringByReplacingOccurrencesOfString:@"lcd-grid.glslp" withString:@"scanlines-finas-suaves.glslp"] stringByReplacingOccurrencesOfString:@"warm-composite.glslp" withString:@"scanlines-finas-marcadas.glslp"];
 if(![updated isEqualToString:config]&&![updated writeToFile:configPath atomically:YES encoding:NSUTF8StringEncoding error:&err])fail(err.localizedDescription);
 if(chdir(data.fileSystemRepresentation))fail(@"No se pudo abrir la carpeta de datos.");
 setenv("SNESRECOMP_ROM_CACHE",[data stringByAppendingPathComponent:@"rom.cfg"].fileSystemRepresentation,1);
 setenv("TMPDIR",[data stringByAppendingPathComponent:@"tmp"].fileSystemRepresentation,1);
 setenv("SNESRECOMP_BEAM_ASYNC_INTERRUPTS","1",1);
 setenv("SNESRECOMP_BEAM_LIVE_RASTER","1",1);
 setenv("SNESRECOMP_BEAM_SCANOUT_CLOCK","512",1);
 int fd=open([data stringByAppendingPathComponent:@"logs/last-run.log"].fileSystemRepresentation,O_CREAT|O_TRUNC|O_WRONLY,0600);
 if(fd<0)fail(@"No se pudo crear el registro.");dup2(fd,1);dup2(fd,2);close(fd);
 NSString *runtime=[NSBundle.mainBundle.executablePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"ff2-runtime"];
 NSMutableArray *args=[NSMutableArray arrayWithArray:@[[data stringByAppendingPathComponent:@"FinalFight2"],@"--config",[data stringByAppendingPathComponent:@"config.ini"]]];
 const char *rom=getenv("PORT_ROM");if(rom)[args addObject:@(rom)];
 for(int i=1;i<argc;i++)if(strncmp(argv[i],"-psn_",5))[args addObject:@(argv[i])];
 char **a=calloc(args.count+1,sizeof(char*));for(NSUInteger i=0;i<args.count;i++)a[i]=strdup([args[i] UTF8String]);
 execv(runtime.fileSystemRepresentation,a);fail(@"No se pudo iniciar el juego.");
}}
