<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="generator" content="NiReports: https://www.nipreps.org/" />
<title>{{ title }}</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>

{% if rating_widget %}
<script>
var timestamp = Date.now()

function read_form() {
    var ds = "{{ dataset or 'unknown' }}";
    var sub = "{{ bids_name }}";

    var artifacts = [];
    $('#artifacts-group input:checked').each(function() {
        artifacts.push($(this).attr('name'));
    });

    var rating = $('#qcslider').val();
    var payload = {
        'dataset': ds,
        'subject': sub,
        'rating': rating,
        'artifacts': artifacts,
        'time_sec': (Date.now() - timestamp) / 1000,
        'confidence': $('#confidence').val(),
        'comments': $('#widget-comments').val()
    };

    var file = new Blob([JSON.stringify(payload)], {type: 'text/json'});
    $('#btn-download').attr('href', URL.createObjectURL(file));
    $('#btn-download').attr('download', payload['dataset'] + "_" + payload['subject'] + ".json");
    return payload
};

function toggle_rating() {
    if ($('#rating-menu').hasClass('d-none')) {
        $('#rating-menu').removeClass('d-none');
        $('#rating-toggler').prop('checked', true);
    } else {
        $('#rating-menu').addClass('d-none');
        $('#rating-toggler').prop('checked', false);
    }
};

$(window).on('load',function(){
    var authorization = $('#btn-post').val()
    if (authorization.includes("secret_token")) {
        $('#btn-post').addClass('d-none');
    };
    timestamp = Date.now();
});

</script>
<style type="text/css">
body {
  font-family: helvetica;
}

.boiler-html {
  font-family: "Bitstream Charter", "Georgia", Times;
}

p.label {
  white-space: nowrap
}

span.qa-fail {
    color: white;
    font-weight: bold;
    background-color: #FF6347;
}

span.qa-pass {
    color: white;
    font-weight: bold;
    background-color: #32CD32;
}

div#accordionOther {
    margin: 0 20px;
}

.add-padding {
    padding-top: 15px;
}

#report-qi2-fitting {
    max-width: 450px;
}

/* The slider itself */
.slider {
  -webkit-appearance: none;  /* Override default CSS styles */
  appearance: none;
  margin-bottom: 8px;
  margin-left: 10%;
  width: 80%;
  height: 5px; /* Specified height */
  background: #d3d3d3; /* Grey background */
  outline: none; /* Remove outline */
  opacity: 0.7; /* Set transparency (for mouse-over effects on hover) */
  -webkit-transition: .2s; /* 0.2 seconds transition on hover */
  transition: opacity .2s;
}

/* Mouse-over effects */
.slider:hover {
  opacity: 1; /* Fully shown on mouse-over */
}

.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 25px;
  height: 25px;
  border: 0;
  background: url('https://raw.githubusercontent.com/nipreps/nireports/main/assets/slider-handle.png');
  cursor: pointer;
  z-index: 2000 !important;
}

.slider::-moz-range-thumb {
  width: 25px;
  height: 25px;
  border: 0;
  background: url('https://raw.githubusercontent.com/nipreps/nireports/main/assets/slider-handle.png');
  cursor: pointer;
  z-index: 2000 !important;
}

</style>
{% endif %}

</head>
<body>

<nav class="navbar fixed-top navbar-expand-lg bg-light">
<div class="container-fluid">
<div class="collapse navbar-collapse" id="navbarSupportedContent">
    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
    {% for sub_report in sections %}
        {% if sub_report.isnested %}
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" id="navbar{{ sub_report.name }}" role="button" data-bs-toggle="dropdown" aria-expanded="false" href="#{{sub_report.name}}">
            {{ sub_report.name }}
            </a>
            <ul class="dropdown-menu">
            {% for run_report in sub_report.reportlets %}
                {% if run_report.title %}
                <li><a class="dropdown-item" href="#{{run_report.name}}">{{run_report.title}}</a></li>
                {% endif %}
            {% endfor %}
            </ul>
        </li>
        {% else %}
        <li class="nav-item"><a class="nav-link" href="#{{sub_report.name}}">{{sub_report.name}}</a></li>
        {% endif %}
    {% endfor %}
    </ul>
</div>
</div>
{% if rating_widget.switch %}
<div class="d-flex flex-row-reverse">
<div class="form-check form-switch align-self-center flex-fill me-4">
<input class="form-check-input" type="checkbox" id="rating-toggler"></input>
<label class="form-check-label" style="width: 100pt;" for="rating-toggler">Rating widget</label>
</div>
</div>
{% endif %}
</nav>
<noscript>
    <h1 class="text-danger"> The navigation menu uses Javascript. Without it this report might not work as expected </h1>
</noscript>

{% for sub_report in sections %}
    {% if sub_report.reportlets %}
    <div id="{{ sub_report.name }}" class="mt-5">
    <h1 class="sub-report-title pt-5 ps-4">{{ sub_report.name }}</h1>
    {% for run_report in sub_report.reportlets %}
        <div id="{{run_report.name}}" class="ps-4 pe-4 mb-2">
            {% if run_report.title %}<h2 class="sub-report-group mt-4">{{ run_report.title }}</h2>{% endif %}
            {% if run_report.subtitle %}<h3 class="run-title mt-3">{{ run_report.subtitle }}</h3>{% endif %}
            {% if run_report.description %}<p class="elem-desc">{{ run_report.description }}</p>{% endif %}
            {% for elem in run_report.components %}
                {% if elem[0] %}
                    {% if elem[1] %}<p class="elem-caption">{{ elem[1] }}</p>{% endif %}
                    {{ elem[0] }}
                {% endif %}
            {% endfor %}
        </div>
    {% endfor %}
    </div>
    {% endif %}
{% endfor %}

{% if rating_widget %}
<div id="rating-menu" class="card position-fixed d-none" style="width: 30%; top: 100px; left: 65%;">
<div class="card-header m-0">Rate Image
    <button type="button" class="btn-close position-absolute top-0 end-0" aria-label="Close" id="close-rating-menu" onclick="toggle_rating()" style="margin: 10px 10px 0 0"></button>
</div>
<div class="card-body">
<div class="accordion">
  <div class="accordion-item">
    <h2 class="accordion-header" id="qcslider-head">
      <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#qcslider-collapse" aria-expanded="true" aria-controls="qcslider-collapse">
        Overall Quality Rating
      </button>
    </h2>
    <div id="qcslider-collapse" class="accordion-collapse collapse show" aria-labelledby="qcslider-head">
      <div class="accordion-body">
        <input type="range" min="1.0" max="4.0" step="0.05" value="2.5" id="qcslider" class="slider">
        <ul class="list-group list-group-horizontal slider-labels" style="width: 100%">
            <li class="list-group-item list-group-item-danger" style="width: 25%; text-align:center">Exclude</button>
            <li class="list-group-item list-group-item-warning" style="width: 25%; text-align:center">Poor</button>
            <li class="list-group-item list-group-item-primary" style="width: 25%; text-align:center">Acceptable</button>
            <li class="list-group-item list-group-item-success" style="width: 25%; text-align:center">Excellent</button>
        </ul>
      </div>
    </div>
  </div>
  <div class="accordion-item">
    <h2 class="accordion-header" id="qcartifacts-head">
      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#qcartifacts-collapse" aria-expanded="false" aria-controls="qcartifacts-collapse">
        Record specific artifacts
      </button>
    </h2>
    <div id="qcartifacts-collapse" class="accordion-collapse collapse" aria-labelledby="qcartifacts-head">
      <div class="accordion-body">
        <fieldset id="artifacts-group" class="form-group">
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="head-motion" id="art1">
                <label class="form-check-label" for="art1">Head motion artifacts</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="eye-spillover" id="art2">
                <label class="form-check-label" for="art2">Eye spillover through PE axis</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="noneye-spillover" id="art3">
                <label class="form-check-label" for="art3">Non-eye spillover through PE axis</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="coil-failure" id="art4">
                <label class="form-check-label" for="art4">Coil failure</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="noise-global" id="art5">
                <label class="form-check-label" for="art5">Global noise</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="noise-local" id="art6">
                <label class="form-check-label" for="art6">Local noise</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="em-perturbation" id="art7">
                <label class="form-check-label" for="art7">EM interference / perturbation</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="wrap-around" id="art8">
                <label class="form-check-label" for="art8">Problematic FoV prescription / Wrap-around</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="ghost-aliasing" id="art9">
                <label class="form-check-label" for="art9">Aliasing ghosts</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="ghosts-other" id="art10">
                <label class="form-check-label" for="art10">Other ghosts</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="inu" id="art11">
                <label class="form-check-label" for="art11">Intensity non-uniformity</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="field-variation" id="art12">
                <label class="form-check-label" for="art12">Temporal field variation</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="postprocessing" id="art13">
                <label class="form-check-label" for="art13">Reconstruction and postprocessing (e.g. denoising, defacing, resamplings)</label>
            </div>
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="uncategorized" id="art0">
                <label class="form-check-label" for="art0">Uncategorized artifact</label>
            </div>
        </fieldset>
        </div>
    </div>
  </div>
  <div class="accordion-item">
    <h2 class="accordion-header" id="widget-misc-head">
      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#widget-misc-collapse" aria-expanded="false" aria-controls="widget-misc-collapse">
        Extra details
      </button>
    </h2>
    <div id="widget-misc-collapse" class="accordion-collapse collapse" aria-labelledby="widget-misc-head">
      <div class="accordion-body">
        <div class="input-group">
          <span class="input-group-text">Comments</span>
          <textarea class="form-control" aria-label="Comments" id="widget-comments"></textarea>
        </div>

        <p style="margin-top: 20px; font-weight: bold">Rater confidence:</p>
        <input type="range" min="0.0" max="4.0" step="0.05" value="3.0" id="confidence" class="slider" style="margin-left: 22%;width: 56%;">
        <ul class="list-group list-group-horizontal slider-labels" style="width: 100%">
            <li class="list-group-item list-group-item-warning" style="width: 50%; text-align:center">Doubtful</button>
            <li class="list-group-item list-group-item-success bg-success text-white" style="width: 50%; text-align:center">Confident</button>
        </ul>
       </div>
    </div>
  </div>
</div>
<div style="margin-top: 10px">
<a class="btn btn-primary disabled" id="btn-download" href="">Download</a>
<button class="btn btn-primary" id="btn-post" value="<secret_token>" disabled>Post to WebAPI</button>
</div>
<script type="text/javascript">
$('#qcslider').on('input', function() {

    if ( (Date.now() - timestamp) / 1000 > 10) {
        $('#btn-download').removeClass('disabled');
        $('#btn-download').removeAttr('aria-disabled');
        $('#btn-post').removeAttr('disabled');
    };

    $('#qcslider-collapse .list-group-item').removeClass(function(index, classname) {
        return (classname.match(/(^|\s)bg-\S+/g) || []).join(' ');
    });
    $('#qcslider-collapse .list-group-item').removeClass(function(index, classname) {
        return (classname.match(/(^|\s)text-\S+/g) || []).join(' ');
    });

    if ( $(this).val() < 1.5 ) {
        $('#qcslider-collapse .list-group-item-danger').addClass('bg-danger text-white');
    } else if ( $(this).val() > 3.5 ) {
        $('#qcslider-collapse .list-group-item-success').addClass('bg-success text-white');
    } else if ( $(this).val() < 2.5 ) {
        $('#qcslider-collapse .list-group-item-warning').addClass('bg-warning text-dark');
    } else {
        $('#qcslider-collapse .list-group-item-primary').addClass('bg-primary text-white');
    };

    var payload = read_form();
});

$('#confidence').on('input', function() {
    if ( (Date.now() - timestamp) / 1000 > 10) {
        $('#btn-download').removeClass('disabled');
        $('#btn-download').removeAttr('aria-disabled');
        $('#btn-post').removeAttr('disabled');
    };

    $('#widget-misc-collapse .list-group-item').removeClass(function(index, classname) {
        return (classname.match(/(^|\s)bg-\S+/g) || []).join(' ');
    });
    $('#widget-misc-collapse .list-group-item').removeClass(function(index, classname) {
        return (classname.match(/(^|\s)text-\S+/g) || []).join(' ');
    });

    if ( $(this).val() < 2.0 ) {
        $('#widget-misc-collapse .list-group-item-warning').addClass('bg-warning text-dark');
    } else {
        $('#widget-misc-collapse .list-group-item-success').addClass('bg-success text-white');
    };

    var payload = read_form();
});


$('#widget-comments').bind('input propertychange', function() {
    if ( (Date.now() - timestamp) / 1000 > 10) {
        $('#btn-download').removeClass('disabled');
        $('#btn-download').removeAttr('aria-disabled');
        $('#btn-post').removeAttr('disabled');
    };
});

$( '#btn-post' ).click( function() {
    var payload = read_form();
    var md5sum = "{{ md5sum }}";
    var params = {
        'rating': payload['rating'],
        'md5sum': md5sum,
        'name': "",
        'comment': JSON.stringify(payload['artifacts'])
    };

    // disable development releases
    var authorization = $(this).val();
    var ratingReq = new XMLHttpRequest();
    ratingReq.open("POST", "{{ webapi_url }}/rating");
    ratingReq.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    ratingReq.setRequestHeader("Authorization", authorization);
    ratingReq.onload = function () {
        status = ratingReq.status;
        $('#btn-post').removeClass('btn-primary');
        $('#btn-post').attr('disabled', true);
        $('#btn-post').attr('aria-disabled', true);
        $('#btn-post').prop('disabled');
        $('#btn-post').addClass('disabled');
        $('#btn-post').removeClass('active');
        if (status === "201") {
            $('#btn-post').addClass('btn-success');
            $('#btn-post').html('Posted!');
        } else {
            $('#btn-post').addClass('btn-danger');
            $('#btn-post').html('Failed');
        };
    };
    ratingReq.send(JSON.stringify(params));
});

$( 'body' ).on( 'click', '#artifacts-group input', function(e) {
    if ( (Date.now() - timestamp) / 1000 > 10) {
        $('#btn-download').removeClass('disabled');
        $('#btn-download').removeAttr('aria-disabled');
        $('#btn-post').removeAttr('disabled');
    };
    
    var payload = read_form();
});

$( 'body' ).on( 'click', '#rating-toggler', function(e) {
    toggle_rating();
});
</script>
</div>
{% endif %}

<script type="text/javascript">
function toggle(id) {
    var element = document.getElementById(id);
    if(element.style.display == 'block')
        element.style.display = 'none';
    else
        element.style.display = 'block';
}

<!-- $(".nav .nav-link").on("click", function(){
   $(".nav").find(".active").removeClass("active");
   $(this).addClass("active");
}); -->
</script>
</body>
</html>
