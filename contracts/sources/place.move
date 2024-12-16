module sui_place::place {
    // use std::vector;
     use sui::transfer::{share_object};
    use sui::dynamic_object_field::{Self};
    // use sui::object::{new};
    // use sui::tx_context::{TxContext};

    const EInvalidCoord:u64 = 0;
    const ESomeOtherErrorCode:u64 = 1;

    public struct Place has key, store {
        id: UID,
    }

    public struct Quadrant has key, store {
        id: UID,
        quadrant_id: u8,
        board: vector<vector<u32>>,
    }

   fun init(ctx: &mut TxContext) {
    // Create place object and declare it mutable
    let mut place = Place {
        id: object::new(ctx)
    };
    
    // Create 4 quadrants, initialize each pixel grid to white
    // Place four quadrants as dynamic fields with quadrant ID on place
    let mut i = 0;
    while (i < 4) {
        dynamic_object_field::add(&mut place.id, i, Quadrant {
            id: object::new(ctx),
            quadrant_id: i,
            board: make_quadrant_pixel(200),
        });
        i = i + 1;
    };
    
    // Make place shared object
    share_object(place);
}


    fun make_row(length:u64):vector<u32>{
      // init empty vector
      let mut row = vector::empty<u32>();
      //append length number of #ffffff
      let mut i = 0;
      while (i < length) {
        vector::push_back(&mut row, 16_777_215);
        i = i + 1;
      };
      //return vector
      row
    }

    fun make_quadrant_pixel(length:u64):vector<vector<u32>>{
      //init empty vector
      let mut grid = vector::empty<vector<u32>>();
      //append result of call to make_row lenngth times
       let mut i = 0;
      while (i < length) {
        vector::push_back(&mut grid, make_row(length));
        i = i + 1;
      };
      //return vector
      grid
    }

    //take x,y
    //return which quadrant x,y falls in
    fun get_quadrant_id(x:u64, y:u64):u8{ 
    if (x < 200) {
        if (y < 200) { 0 } else { 2 }
    } else {
        if (y < 200) { 1 } else { 3 }
    }
    }

    public fun set_pixels_at(place: &mut Place, x:u64, y:u64, color: u32) {
      //assert that x,y is in bounds
     assert!(x < 400 && y < 400, Self::EInvalidCoord);
      //get quadrant id from x,y
      let quadrant_id = get_quadrant_id(x,y);
      //get quadrant from dynamic field object mapping on place
     let quadrant=  dynamic_object_field::borrow_mut<u8,Quadrant>(&mut place.id,quadrant_id);
     let pixel= vector::borrow_mut(vector::borrow_mut(&mut quadrant.board,x%200),y%200);
      //place the pixel in the quadrant
      *pixel= color;

    }

    // public fun get_quadrants(place: &mut Place):vector<address> {
    //   //Create an empyy vector
    //   //iterate from 0 to 3
    //   //lookup quadrant in object mapping from quadrant id
    //   //append id of each quadrant to vector
    //   //return vector
    // }
  
}
