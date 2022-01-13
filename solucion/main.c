#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

char* palos[5] = {"espada","oro","palo","copa","espada"};

int main (void){    
    FILE* pfile;

    pfile = fopen("pruebasCortas.txt", "w");


    // =============================================
    // |                                            |
    // |              TETS: CASO ARRAY              |
    // |                                            |
    // =============================================

    fprintf(pfile, "---TEST PROPIOS: CASO ARRAY ---\n\n Creamos mazo de 5 cartas con array: \n\n");
    uint8_t capacity = 5;
    array_t *array = arrayNew(TypeCard, capacity);

    // Primero creamos un mazo de 5 cartas sobre el arreglo

    for(int32_t j=1; j<6; ++j){
    
     card_t *c = cardNew(palos[j-1],&j);
    // agregamos las cartas
    
    arrayAddLast(array,c);
    cardDelete(c);
    }
    arrayPrint(array,pfile);

    fprintf(pfile, "\n\nApilamos una carta del mazo en otra:  \n\n" );

    cardAddStacked(arrayGet(array, 1), arrayGet(array, 0));


    //imprimimos el mazo


    arrayPrint(array, pfile);

    fprintf(pfile, "\n\nFin test corto Array!\n" );
    fprintf(pfile, "\n\n ");
    //borramos el mazo
    arrayDelete(array);



    // =============================================
    // |                                            |
    // |              TETS: CASO LIST               |
    // |                                            |
    // =============================================


//  Primero creamos un mazo de 5 cartas sobre la lista

    fprintf(pfile, "---TEST PROPIOS: CASO LIST ---\n\n Creamos mazo de cartas con list: \n\n");

    list_t *list = listNew(TypeCard);

    for(int32_t j=1; j<6; ++j){
        card_t *ci = cardNew(palos[j-1],&j);
        // agregamos las cartas
        listAddLast(list,ci);

        cardDelete(ci);
    }
    // imprimimos mazo
    listPrint(list, pfile);

    //apilamos una carta nueva sobre otra cualquiera
    cardAddStacked(listGet(list, 1), listGet(list, 0));

    //imprimimos el mazo
    fprintf(pfile, "\n\nApilamos una carta sobre otra: \n\n");
    listPrint(list, pfile);
    fprintf(pfile, "\n\n Fin test corto List!\n\n ");
    //borramos el mazo
    listDelete(list);
    fprintf(pfile, "\n\n FIN DE LAS PRUEBAS CORTAS :)!\n\n ");

    fclose(pfile);
    
    return 0;
}


