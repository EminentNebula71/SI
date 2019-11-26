$(document).ready(function(){
    $("#1").keyup(function(event){
        var progress = 0;
        if($("#1").val().length<8){
            $("#2").val(0);
        }
        else{
            if($("#1").val().length>=8){
                progress+=50;
                $("#2").val(progress);
            }
            if(($("#1").val().toLowerCase()!=$("#1").val())&&(($("#1").val().toUpperCase()!=$("#1").val()))){
                progress+=50;
                $("#2").val(progress);
            }    
        }
        
    });
});