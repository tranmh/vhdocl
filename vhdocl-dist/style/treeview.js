/*  Tree view functionality based on example by Daniel Thoma, see
    http://aktuell.de.selfhtml.org/artikel/javascript/treemenu/     */

  /* 
   * Set class of tree view nodes to closed (or to saved prior state if
   * applicable).  Install event handler on bullet image, not list text,
   * because in VHDocL output, these are all links which should not close/open
   * the nodes.
   * 
   * menu: Reference to HTML element above all tree nodes
   * openstr: String containing open node numbers separated by spaces in 
   *            ascending order (save from last time by treeMenu_store()).
   */
  function treeMenu_init(menu, openstr) {
    var open_indices = new Array(0);
    if(openstr != null && openstr != "") {
      open_indices = openstr.match(/\d+/g);
    }
    var items = menu.getElementsByTagName("dd");
    for(var i = 0; i < items.length; i++) {
      var setstate;
      if(open_indices.length > 0 && open_indices[0] == i) {
        setstate= "treeMenu_opened";
        open_indices.shift();
      }
      else {
        setstate= "treeMenu_closed";
      }
      if( items[i].getElementsByTagName("dl").length == 0 ) {
        continue;
      }
      items[i].className = setstate;
      /* install click handler on bullet image */
      var images = items[i].getElementsByTagName("img"); 
      if( images.length > 0 ) {
        images[0].onclick = treeMenu_handleClick;
      }
    }
  }
  
  /*
   * Click handler which opens or closes tree nodes.
   *
   * event: event object from browser
   */
  function treeMenu_handleClick(event) {
    var tree_node;
    if(event == null) {         // Workaround for IE
      event = window.event;
      tree_node = event.srcElement;
      event.cancelBubble = true;
    }
    else {
      event.stopPropagation();
      tree_node = event.currentTarget;
    }
    while(tree_node.nodeName.toLowerCase() != "dd") {
      tree_node = tree_node.parentNode;
    }
    if( tree_node.className == "treeMenu_opened" ) {
      tree_node.className = "treeMenu_closed";
    }
    else {
      tree_node.className = "treeMenu_opened";
    }
  }

  /*
   * Close or open the whole tree
   * 
   * menu: Reference to HTML element above all tree nodes
   * closeTree: if true, close all
   */
  function treeMenu_closeOrOpenAll(menu, closeTree) {

    var setstate= closeTree ? "treeMenu_closed" : "treeMenu_opened";

    var items = menu.getElementsByTagName("dd");

    for(var i = 0; i < items.length; i++) {

        items[i].className= setstate;
    }
  }

  /*
   * Build space-separated string of indices of open nodes in ascending order.
   * menu: reference to HTML element above all nodes
   * return: string
   */
  function treeMenu_store(menu) {
    var result = new Array();
    var items = menu.getElementsByTagName("dd");
    for(var i = 0; i < items.length; i++) {
      if(items[i].className && items[i].className == "treeMenu_opened" ) {
        result.push(i);
      }
    }
    return result.join(" ");
  }

