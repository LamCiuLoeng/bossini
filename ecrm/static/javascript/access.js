$(document).ready(function(){


    $(".group").click(function(){
          parentCB = $(this);
          if( $(this).attr("checked") ){
              $(".permission",parentCB.parent("li")).each(function(){
                  $(this).attr("checked","checked");
              });
          }else{
              $(".permission",parentCB.parent("li")).each(function(){
                  $(this).removeAttr("checked");
              });
          }

      });



      $(".permission").click(function(){
           pCB = $(this)
           if( pCB.attr("checked") ){
               $(".group",pCB.parents("li")).attr("checked","check");
           }else{
               var flag = true;
               $(".permission",pCB.parents("li")).each(function(){
                   if( $(this).attr("checked") ){ flag = false; }
               });

               if(flag){
                   $(".group",pCB.parents("li")).removeAttr("checked");
               }
           }
      });



      $(".tableform").submit(function(){
            formObj = $(this);

            var p_val = "";
            $(".group").each(function(){
                if( $(this).attr("checked") ){
                    var groupObj = $(this);
                    p_val += groupObj.val() + ":";
                    $(".permission",$(this).parent("li")).each(function(){
                        if( $(this).attr("checked") ){
                            p_val += $(this).val()+ "|";
                        }
                    });

                    p_val += ";";
                }
            });

            formObj.append( '<input type="hidden" name="permissions_info" value="' + p_val + '"/>' );

           return true;
        });


});