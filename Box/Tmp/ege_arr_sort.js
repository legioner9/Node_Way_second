let c = 0;
const arr = [ 4, 1, 2, 3 ];
debugger
for ( let i = 1 ; i < 4 ; i++) {
    if ( arr[i-1] > arr[i] ) {
        c++;
        let t = arr[i - 1];
        arr[i - 1] = arr[i];
        arr[i] = t;
    }
}
debugger;