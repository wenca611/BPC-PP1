function func = calcFunctions
% vsechny funkce
func.keyPressF = @keyPressF;
func.pushSciB = @pushSciB;
func.pushNumB = @pushNumB;
func.pushClaB = @pushClaB;
func.updateEdit = @updateEdit;
func.bselection1 = @bselection1;
func.bselection2 = @bselection2;
func.bselection3 = @bselection3;
func.bselection4 = @bselection4;
func.bselection5 = @bselection5;
end

function keyPressF(~,event)
% chyceni enteru
if strcmp(event.Key,'return') || strcmp(event.Key,'equal')
   pushClaB('','','=');
end
end

function pushSciB(~,~,button)
% konkatenace retezce s hodnotou tlacitka v prikazovem radku
edit = findobj(0,'Style','edit');
switch button
   case {'sin(x)','cos(x)','tan(x)','cot(x)','log(x)',...
         'gamma(x)','sqrt(x)','()','asin(x)','acos(x)','atan(x)'}
      button = regexprep(button,'x','');
   case char(960)
      button = 'pi';
   case 'e'
      button = num2str(exp(1));
   case strcat('log',char(8321),char(8320),'(x)')
      button = 'log10()';
   case strcat('log',char(8322),'(x)')
      button = 'log2()';
   case 'x!'
      button = 'factorial()';
   case '|x|'
      button = 'abs()';
   case '<html>x<sup>y'
      button = '^';
   case '<html>e<sup>x'
      button = 'exp()';
   case '<html>10<sup>x'
      button = '10^()';
end
set(edit,'String',strcat(edit.String,button));
end

function pushNumB(~,~,button)
% konkatenace retezce s hodnotou tlacitka v prikazovem radku
edit = findobj(0,'Style','edit');
set(edit,'String',strcat(edit.String,button));
end

function pushClaB(~,~,button)
% fungovani tlacitek a vypis
edit = findobj(0,'Style','edit');
switch button
   case 'DEL'
      set(edit,'String',edit.String(1:end-1));
   case 'AC'
      set(edit,'String','');
   case '='
      upEdit = updateEdit(edit.String);
      upEdit = regexprep(upEdit,'Ans',edit.Parent.UserData.editD,'ignorecase');
      splitInput = strsplit(upEdit,':');
      sizeI = size(splitInput,2);
      % vypocet
      try
         if sizeI == 1
            axes.x = eval(str2sym(upEdit));
            concatI = upEdit;
         end
         if sizeI > 3
            set(edit,'String','ERR');
            return;
         end
         if sizeI > 1
            splitStart = flip(cell2mat(splitInput(1)));
            splitStart = flip(splitStart(1:find(...
               cumsum((splitStart == ']' )-(splitStart == '[')) < 0,1)));
            
            splitEnd = cell2mat(splitInput(end));
            splitEnd = splitEnd(1:find(...
               cumsum((splitEnd == '[' )-(splitEnd == ']')) < 0,1));
            
            if sizeI == 3
               splitMid = cell2mat(splitInput(2));
               splitMid = cumsum((splitMid == ')' )-(splitMid == '('));
               if splitMid(end)
                  set(edit,'String','ERR');
                  return;
               end
               concatI = strcat(splitStart,':',cell2mat(splitInput(2)),':',splitEnd);
               axes.x = eval(str2sym(concatI));
            else
               concatI = strcat(splitStart,':',splitEnd);
               axes.x = eval(str2sym(concatI));
            end
         end
         
         if size(str2sym(upEdit),1) > 1
            set(edit,'String','ERR');
            return;
         end
         axes.y = eval(str2sym(upEdit));
         set(edit,'String',num2str(axes.y));
      catch
         set(edit,'String','ERR');
         return;
      end
      if ~strcmp(edit.String,'ERR')
         edit.Parent.UserData.editD = edit.String;
         color = edit.Parent.UserData.color;
         darkgray = color.darkgray;
         green = color.green;
         if any(~isreal(axes.x)) || any(~isreal(axes.y))
            set(edit,'String','ERR');
            return;
         end
         lengthX = 1:length(axes.x);
         % vykresleni grafu
         if edit.Parent.UserData.optD
            for i = lengthX
               plot(gca, axes.x(i), axes.y(i),'');
               hold on;
               plot(gca, axes.x(1:i), axes.y(1:i));
               if edit.Parent.UserData.darkM
                  set(gca,'color',darkgray,'xcolor',green,'ycolor',green);
               end
               pause(0.05);
            end
            hold off;
         else
            plot(gca, axes.x(lengthX), axes.y(lengthX),'');
            if edit.Parent.UserData.darkM
               set(gca,'color',darkgray,'xcolor',green,'ycolor',green);
            end
         end
         concatI = erase(concatI,{'[',']'});
         xlabel(concatI);
         upEdit = erase(upEdit,{'[',']'});
         ylabel(upEdit);
      end
   otherwise
      set(edit,'String',strcat(edit.String,button));
end
end

function upEdit = updateEdit(edit)
% pridani hranatych zavorek pro spravne vyhodnoceni vstupu
edit = regexprep(edit,'(','([');
edit = regexprep(edit,')','])');
upEdit = strcat('[',edit,']');
end


function bselection1(source,event)
% prepnuti jazyka
lang = findall(0,'Tag','lang');
type = findall(0,'Tag','type');
cla = findall(0,'Tag','cla');
sci = findall(0,'Tag','sci');
graph = findall(0,'Tag','graph');
on = findall(0,'Tag','on');
off = findall(0,'Tag','off');
optim = findall(0,'Tag','optim');
mode = findall(0,'Tag','mode');
if strcmp(event.NewValue.Tag,'cz')
   source.Parent.Name = 'Kalkulaèka';
   cla.String = 'Standardní';
   sci.String = 'Vìdecká';
   lang.String = 'Jazyk';
   type.String = 'Typ';
   graph.String = 'Graf';
   optim.String = 'Optimalizace';
   mode.String = 'Tmavý režim';
   for i = 1:3
      on(i).String = 'Zapnut';
      off(i).String = 'Vypnut';
      if strcmp(on(i).Parent.Tag,'bg4')
         on(i).String = strcat(on(i).String,'a');
         off(i).String = strcat(off(i).String,'a');
      end
   end
elseif strcmp(event.NewValue.Tag,'en')
   source.Parent.Name = 'Calculator';
   cla.String = 'Classic';
   sci.String = 'Scientific';
   lang.String = 'Language';
   type.String = 'Type';
   graph.String = 'Graph';
   optim.String = 'Optimalization';
   mode.String = 'Dark mode';
   for i = 1:3
      on(i).String = 'On';
      off(i).String = 'Off';
   end
end
end

function bselection2(source,event)
% prepnuti grafu
panel = findall(0,'Tag','panel');
posFon = 775;
posFoff = 432;
buttongroup = findall(0,'Type','uibuttongroup');
if strcmp(event.NewValue.Tag,'off')
   panel.Visible = 'off';
   source.Parent.Position(4) = posFoff;
   for i = 1:5
      buttongroup(i).Position(2) = posFoff-80;
   end
elseif strcmp(event.NewValue.Tag,'on')
   panel.Visible = 'on';
   source.Parent.Position(4) = posFon;
   for i = 1:5
      buttongroup(i).Position(2) = posFon-80;
   end
end
end

function bselection3(source,event)
% prepnuti typu kalkulacky
panel = findall(0,'Tag','panel');
edit = findall(0,'Tag','edit');
buttonSci = flipud(findall(0,'-regexp','Tag','^sci\d+$'));
posCla = 535;
posSci = 1035;
visible = 'off';
if strcmp(event.NewValue.Tag,'cla')
   source.Parent.Position(3) = posCla;
   panel.Position(3) = posCla - 35;
   edit.Position(3) = posCla - 35;
elseif strcmp(event.NewValue.Tag,'sci')
   source.Parent.Position(3) = posSci;
   panel.Position(3) = posSci - 35;
   edit.Position(3) = posSci - 35;
   visible = 'on';
end
for i = 1:20
   buttonSci(i).Visible = visible;
end
end

function bselection4(source,event)
% prepnuti optimalizace
if strcmp(event.NewValue.Tag,'off')
   source.Parent.UserData.optD = 1;
elseif strcmp(event.NewValue.Tag,'on')
   source.Parent.UserData.optD = 0;
end
end

function bselection5(source,event) %~
% zmena barvy
panel = findall(0,'Tag','panel');
edit = findall(0,'Tag','edit');
buttongroup = findall(0,'Type','uibuttongroup');
text = findall(0,'Style','text');
radiobutton = findall(0,'Style','radiobutton');
pushbutton = findall(0,'Style','pushbutton');
color = source.Parent.UserData.color;
white = color.white;
black = color.black;
darkgray = color.darkgray;
gray = color.gray;
green = color.green;
blue = color.blue;
darkwhite = color.darkwhite;
shadow = color.shadow;
if strcmp(event.NewValue.Tag,'off')
   set(gca,'color',white,'xcolor',black,'ycolor',black);
   source.Parent.UserData.darkM = 0;
   source.Parent.Color = darkwhite;
   panel.BackgroundColor = white;
   panel.HighlightColor = black;
   edit.BackgroundColor = white;
   edit.ForegroundColor = black;
   for i = 1:10
      buttongroup(fix((i+1)/2)).BackgroundColor = darkwhite;
      buttongroup(fix((i+1)/2)).HighlightColor = white;
      buttongroup(fix((i+1)/2)).ShadowColor = shadow;
      text(fix((i+1)/2)).BackgroundColor = darkwhite;
      text(fix((i+1)/2)).ForegroundColor = black;
      radiobutton(i).BackgroundColor = darkwhite;
      radiobutton(i).ForegroundColor = black;
      for j = 0:3
         pushbutton(i+j*10).BackgroundColor = darkwhite;
         pushbutton(i+j*10).ForegroundColor = blue;
      end
   end
   
elseif strcmp(event.NewValue.Tag,'on')
   set(gca,'color',darkgray,'xcolor',green,'ycolor',green);
   source.Parent.UserData.darkM = 1;
   source.Parent.Color = black;
   panel.BackgroundColor = gray;
   panel.HighlightColor = green;
   edit.BackgroundColor = darkgray;
   edit.ForegroundColor = green;
   for i = 1:10
      buttongroup(fix((i+1)/2)).BackgroundColor = gray;
      buttongroup(fix((i+1)/2)).HighlightColor = gray;
      buttongroup(fix((i+1)/2)).ShadowColor = green;
      text(fix((i+1)/2)).BackgroundColor = gray;
      text(fix((i+1)/2)).ForegroundColor = green;
      radiobutton(i).BackgroundColor = gray;
      radiobutton(i).ForegroundColor = green;
      for j = 0:3
         pushbutton(i+j*10).BackgroundColor = gray;
         pushbutton(i+j*10).ForegroundColor = green;
      end
   end
end
end