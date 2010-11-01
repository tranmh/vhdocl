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
    var items = menu.getElementsByTagName("li");
    for(var i = 0; i < items.length; i++) {
      var setstate;
      if(open_indices.length > 0 && open_indices[0] == i) {
        setstate= "treeMenu_opened";
        open_indices.shift();
      }
      else {
        setstate= "treeMenu_closed";
      }
      if( items[i].getElementsByTagName("ul").length
          + items[i].getElementsByTagName("ol").length == 0 ) {
        continue;
      }
      if( !items[i].className ) {
        items[i].className = setstate;
      }
      else if( items[i].className.search(/\btreeMenu_\w+\b/) < 0 ) {
        items[i].className = items[i].className.concat(" ").concat(setstate);
      }
      else {
        items[i].className =
                items[i].className.replace(/\btreeMenu_\w+\b/, setstate);
      }
      /* install click handler on bullet image */
      var images = items[i].getElementsByTagName("img"); 
      if( images.length > 0 ) {
        images[0].onclick = treeMenu_handleClick;
      }
    }
  }
  
  /*
   * Ändert die Klasse eines angeclickten Listenelements, sodass
   * geöffnete Menüpunkte geschlossen und geschlossene geöffnet
   * werden.
   *
   * event: Das Event Objekt, dass der Browser übergibt.
   */
  function treeMenu_handleClick(event) {
    var tree_node;
    if(event == null) { //Workaround für die fehlenden DOM Eigenschaften im IE
      event = window.event;
      tree_node = event.srcElement;
      event.cancelBubble = true;
    }
    else {
      event.stopPropagation();
      tree_node = event.currentTarget;
    }
    while(tree_node.nodeName.toLowerCase() != "li") {
      tree_node = tree_node.parentNode;
    }
    if( tree_node.className.search(/\btreeMenu_opened\b/) >= 0 ) {
      tree_node.className =
        tree_node.className.replace(/\btreeMenu_opened\b/, "treeMenu_closed");
    }
    else {
      tree_node.className =
        tree_node.className.replace(/\btreeMenu_closed\b/, "treeMenu_opened");
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

    var items = menu.getElementsByTagName("li");

    for(var i = 0; i < items.length; i++) {

        items[i].className=
                items[i].className.replace(/\btreeMenu_\w+\b/, setstate);
    }
  }

  /*
   * Build space-separated string of indices of open nodes in ascending order.
   * menu: reference to HTML element above all nodes
   * return: string
   */
  function treeMenu_store(menu) {
    var result = new Array();
    var items = menu.getElementsByTagName("li");
    for(var i = 0; i < items.length; i++) {
      if(items[i].className &&
            items[i].className.search(/\btreeMenu_opened\b/) >= 0) {
        result.push(i);
      }
    }
    return result.join(" ");
  }

