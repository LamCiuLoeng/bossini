function formatFloat(x,l){
   var f_x = parseFloat(x);
   
   if(isNaN(f_x)){
      //alert('function:changeTwoDecimal->parameter error');
      return "";
   }
   var f_x = Math.round(x*Math.pow(10,l))/Math.pow(10,l);
   var s_x = f_x.toString();
   var pos_decimal = s_x.indexOf('.');
   if(pos_decimal < 0){
      pos_decimal = s_x.length;
      s_x += '.';
   }
   while(s_x.length <= pos_decimal + l){
      s_x += '0';
   }
   return s_x;
}