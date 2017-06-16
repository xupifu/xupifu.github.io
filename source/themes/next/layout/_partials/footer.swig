<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }} - 至今 </span>
  <span class="author" itemprop="copyrightHolder">版权所有，任何转载请注明来源，商业转载请联系作者 [{{ config.author }}] </span>
</div>

