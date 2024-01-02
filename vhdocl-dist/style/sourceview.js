/*  Tree view functionality based on example by Daniel Thoma, see
    http://aktuell.de.selfhtml.org/artikel/javascript/treemenu/     */

  /* 
   * Set class of tree view nodes to closed (or to saved prior state if
   * applicable).  Install event handler on bullet images to allow opening
   * one or all levels.
   * 
   * menu: Reference to HTML element above all tree nodes
   * openstr: String containing open node numbers separated by spaces in 
   *            ascending order (save from last time by sourceView_store()).
   */
  function sourceView_init(menu, openstr) {
    var open_indices = new Array(0);
    if(openstr != null && openstr != "") {
      open_indices = openstr.match(/\d+/g);
    }
    var items = menu.getElementsByTagName("tbody");
    for(var i = 0; i < items.length; i++) {
      var setstate;
      if(open_indices.length > 0 && open_indices[0] == i) {
        setstate= "sourceView_opened";
        open_indices.shift();
      }
      else {
        setstate= "sourceView_closed";
      }
      items[i].className = setstate;
      items[i].getElementsByTagName("tr")[0].className= setstate;
      /* exempt first cell containing directory name from visibility toggle */
      items[i].getElementsByTagName("td")[0].className= "always"; 
      /* install click handler on bullet image */
      var images = items[i].getElementsByTagName("img"); 
      if( images.length > 0 ) {
        images[0].onclick = sourceView_toggle1Level;
      }
      if( images.length > 1 ) {
        images[1].onclick = sourceView_toggleRecursive;
      }
    }
  }

  /*
   * Click handler which opens or closes one level of tree nodes.
   *
   * event: event object from browser
   */
  function sourceView_toggle1Level(event) {
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
    while(tree_node.nodeName.toLowerCase() != "tbody") {
      tree_node = tree_node.parentNode;
    }
    if( tree_node.className == "sourceView_opened" ) {
      tree_node.className = "sourceView_closed";
      tree_node.getElementsByTagName("tr")[0].className = "sourceView_closed";
    }
    else {
      tree_node.className = "sourceView_opened";
      tree_node.getElementsByTagName("tr")[0].className = "sourceView_opened";
    }
  }

  /*
   * Click handler which opens or closes subnodes recursively.
   *
   * event: event object from browser
   */
  function sourceView_toggleRecursive(event) {
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
    while(tree_node.nodeName.toLowerCase() != "tbody") {
      tree_node = tree_node.parentNode;
    }
    if( sourceView_anyClosed(tree_node) ) {
      tree_node.className = "sourceView_opened";
      tree_node.getElementsByTagName("tr")[0].className = "sourceView_opened";
      sourceView_closeOrOpenAll(tree_node, false);
    }
    else {
      tree_node.className = "sourceView_closed";
      tree_node.getElementsByTagName("tr")[0].className = "sourceView_closed";
      sourceView_closeOrOpenAll(tree_node, true);
    }
  }

  /*
   * Find out if a node or any sub-node is closed
   * 
   * node: Reference to tree node
   */
  function sourceView_anyClosed(node) {

    if( node.className == "sourceView_closed" ) {
        return true;
    }

    var items = node.getElementsByTagName("tbody");

    for(var i = 0; i < items.length; i++) {
        if( items[i].className == "sourceView_closed" ) {
            return true;
        }
    }
    return false;
  }

  /*
   * Close or open the whole tree
   * 
   * menu: Reference to HTML element above all tree nodes
   * closeTree: if true, close all
   */
  function sourceView_closeOrOpenAll(menu, closeTree) {

    var setstate= closeTree ? "sourceView_closed" : "sourceView_opened";

    var items = menu.getElementsByTagName("tbody");

    for(var i = 0; i < items.length; i++) {
      items[i].className= setstate;
      items[i].getElementsByTagName("tr")[0].className= setstate;
    }
  }

  /*
   * Build space-separated string of indices of open nodes in ascending order.
   * menu: reference to HTML element above all nodes
   * return: string
   */
  function sourceView_store(menu) {
    var result = new Array();
    var items = menu.getElementsByTagName("tbody");
    for(var i = 0; i < items.length; i++) {
      if(items[i].className && items[i].className == "sourceView_opened" ) {
        result.push(i);
      }
    }
    return result.join(" ");
  }

