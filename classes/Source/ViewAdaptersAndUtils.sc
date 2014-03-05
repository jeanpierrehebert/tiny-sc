/* 
Combine a View with a ControlSpec

+ Utilities for testing views quickly

IZ Wed, Mar  5 2014, 07:30 EET

*/

QSli {
    *new { | name = "slider" |
        var w, s;
        w = Window(name, Rect(0, 0, 150, 30)).front;
        w.view.layout = HLayout(s = Slider().orientation_(\horizontal));
        ^s;
    }
}

MappingView {
    var <view;
    var <>spec;

    *new { | view, spec |
        ^this.newCopyArgs(view, spec.asSpec);
    }

    makeSourceAction { | source |
        view.action = {
            source.changed(\value, spec map: view.value);
        };
        /* return self */
    }
    start { | source |
        this.makeSourceAction(source);
    }
    stop { view.action = nil }
    isPlaying { ^view.action.notNil }
    set { | param, val |
        // make views work as listeners of a source
        { view.value = val; }.defer;
    }
}

// Could define these in Nil instead. But no: 
// We want to see errors when trying to map nil (unset variable) instead of a spec!
NullSpec {
    *map { | val | ^val }
    *unmap { | val | ^val }
    *asSpec { ^this }
}

+ Nil {
    asSpec { ^NullSpec }
}

/* Note: Cannot define this in View, because it is a redirect class, and returns
platform specific classes instead.  Therefore, doing it for QT.  Other GUI
    classes can be added in a similar way */

+ QView {
    makeSourceAction { | source |
        ^MappingView(this).makeSourceAction(source);
    }

    map { | spec |
        ^MappingView(this, spec.asSpec); 
    }
    /*
    makeSourceAction { | source | 
        this.action = { source.changed(\value, this.value) };
        /* return self */
    }
    start { | source |
        this.makeSourceAction(source);
    }
    stop { this.action = nil }
    isPlaying { ^this.action.notNil }
    set { | param, val |
        // make views work as listeners of a source
        { this.value = val; }.defer;
    }
    */
}